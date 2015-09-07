//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "WebServiceClient.h"
#import "Fingerprint.h"
#import "KeychainItemWrapper.h"
#import "AppDelegate.h"

#import <CommonCrypto/CommonHMAC.h>

#define DEBUG_LOCAL_URL @"http://localhost:8080/com.nesolabs.FingerprintServer/fingerprint"
#define DEBUG_HOME_URL  @"http://<IP>:8080/com.nesolabs.FingerprintServer/fingerprint"
#define PRD_SERVER_URL  @"http://<IP>:8080/FingerprintService/fingerprint"
#define PUSH_NOTIF_URL  @"http://<IP>:8080/FingerprintService/pushToken"
#define ERR_MSG_URL     @"http://<IP>:8080/FingerprintService/error"

@interface WebServiceClient ()

@property (assign, nonatomic) id <WebServiceClientDelegate> delegate;

@end

@implementation WebServiceClient {
    NSMutableData *_receivedData;
    NSDictionary *_errorDict;
}

+ (id)sharedClient
{
    static dispatch_once_t once_token;
    static id sharedInstance;
    dispatch_once(&once_token, ^{
        sharedInstance = [[WebServiceClient alloc] init];
    });
    return sharedInstance;
}

- (void)sendFingerprint:(Fingerprint *)fingerprint delegate:(id<WebServiceClientDelegate>)delegate
{
    self.delegate = delegate;
    
    // Aufräumen
    _errorDict = nil;
    
    NSError *error;
    NSDictionary *fingerprintInformation = fingerprint.fingerprintInformation;
    
    // Prüfe, ob im Keychain ein Cookie vorhanden ist
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"FingerprintCookie" accessGroup:nil];
    NSData *cookieData = [keychainWrapper objectForKey:(__bridge id)(kSecValueData)];
    NSString *cookie = [[NSString alloc] initWithData:cookieData encoding:NSUTF8StringEncoding];
    
    if (!cookie || cookie.length > 0) {
        [fingerprintInformation setValue:cookie forKey:kCOOKIE];
    }
    
    NSData *fingerprintData = [NSJSONSerialization dataWithJSONObject:fingerprintInformation options:0 error:&error];
    
    if (error) {
        _errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Error in jsonserialization", @"errorType", fingerprintInformation.description, @"fingerprintString", error.description, @"errorDescription", nil];
        ErrLog(error);
        [self askToSendErrorReport];
        
    } else {
        
        // POST Request with JSON content
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:PRD_SERVER_URL]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:fingerprintData];
        [request setTimeoutInterval:30.0];
        
        // HMAC
        [self setHMACHeader:fingerprintData intoRequest:request];
        
        // Start connection
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    }
}

- (void)askToSendErrorReport
{
    NSString *title = NSLocalizedString(@"Fehler!", @"Fehler!");
    NSString *message = NSLocalizedString(@"Ein unbekannter Fehler ist aufgetreten. Möchten Sie einen Fehlerbericht senden?", @"Ein unbekannter Fehler ist aufgetreten. Möchten Sie einen Fehlerbericht senden?");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Nicht senden", @"Nicht senden") otherButtonTitles:NSLocalizedString(@"Senden", @"Senden"), nil];
    [alertView show];
}

- (void)sendErrorReport:(NSDictionary *)errorDict
{
    // Aufräumen
    self.delegate = nil;
    
    NSData *body = [NSJSONSerialization dataWithJSONObject:errorDict options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:ERR_MSG_URL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    [request setTimeoutInterval:30.0];
    
    [self setHMACHeader:body intoRequest:request];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)setDefaultHMACHeaderIntoRequest:(NSMutableURLRequest *)request
{
    NSString *defaultHMAC = @"eed0e215ab631e05bc28968c6b837607a7318558";
    [request setValue:defaultHMAC forHTTPHeaderField:@"Authorization"];
}

- (void)setHMACHeader:(NSData *)data intoRequest:(NSMutableURLRequest *)request
{
    if (!data) {
        [self setDefaultHMACHeaderIntoRequest:request];
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!jsonString) {
        [self setDefaultHMACHeaderIntoRequest:request];
        return;
    }
    
    const char *cKey  = [kCIInputSharpnessKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    if (cKey == NULL || cData == NULL) {
        [self setDefaultHMACHeaderIntoRequest:request];
        return;
    }
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hashData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:[hashData length]];
    const unsigned char *byte = [hashData bytes];
    const unsigned char *endByte = byte + [hashData length];
    for (; byte != endByte; ++byte) [str appendFormat:@"%02x", *byte];
    NSString *hex = str;
    
    [request setValue:hex forHTTPHeaderField:@"Authorization"];
}

- (void)sendPushNotificationToken:(NSData *)token
{
    // Aufräumen
    self.delegate = nil;
    
    // Wandle token in String dann in JSON um
    NSString *tokenString = [[token description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *tokenDict = [NSDictionary dictionaryWithObjectsAndKeys:tokenString, @"token", [[NSLocale preferredLanguages] objectAtIndex:0], @"language", nil];
    NSError *error;
    NSData *tokenJSON = [NSJSONSerialization dataWithJSONObject:tokenDict options:0 error:&error];
    if (error) {
        ErrLog(error);
    }
    
    // POST Request with JSON content
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:PUSH_NOTIF_URL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:tokenJSON];
    [request setTimeoutInterval:10.0];
    
    // HMAC
    [self setHMACHeader:tokenJSON intoRequest:request];
    
    // Start connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Deaktiviere NetworkActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([connection.originalRequest.URL isEqual:[NSURL URLWithString:ERR_MSG_URL]]) {
        NSString *title = NSLocalizedString(@"Fehler!", @"Fehler!");
        NSString *message = NSLocalizedString(@"Beim Senden des Fehlerberichts ist ein Fehler aufgetreten. Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.", @"Beim Senden des Fehlerberichts ist ein Fehler aufgetreten. Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.?");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // Erzeuge neues response-Dictionary mit Fehlermeldung
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:@YES, @"requestFailed", [NSString stringWithFormat:NSLocalizedString(@"Fehler bei der Verbindung zum Server: %@", @"Fehler bei der Verbindung zum Server: %@"), error.localizedDescription], @"errorDescription", nil];
    
    // Sende webservice-ergebnis an delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendingFingerprintFinishedWithResult:)]) {
        [self.delegate performSelector:@selector(sendingFingerprintFinishedWithResult:) withObject:response];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([connection.originalRequest.URL isEqual:[NSURL URLWithString:PUSH_NOTIF_URL]] || [connection.originalRequest.URL isEqual:[NSURL URLWithString:ERR_MSG_URL]]) {
        // Deaktiviere NetworkActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // Gehe zurück zu rootView
        [(UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController] popToRootViewControllerAnimated:YES];
    } else {
        // Parse JSON response
        NSError *error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            ErrLog(error);
            response = [NSDictionary dictionaryWithObjectsAndKeys:@YES, @"requestFailed", [NSString stringWithFormat:NSLocalizedString(@"Fehler beim Verarbeiten des Ergebnisses: %@", @"Fehler beim Verarbeiten des Ergebnisses: %@"), error.localizedDescription], @"errorDescription", nil];
        } else {
            [[Fingerprint sharedFingerprint] setIsSent:YES];
            // Teile AppDelegate mit, dass gesendet wurde
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setApplicationState:ApplicationStateSent];
        }
        
        // Sende webservice-ergebnis an delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendingFingerprintFinishedWithResult:)]) {
            [self.delegate performSelector:@selector(sendingFingerprintFinishedWithResult:) withObject:response];
        }
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self sendErrorReport:_errorDict];
    } else {
        [(UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController] popToRootViewControllerAnimated:YES];
    }
}

@end

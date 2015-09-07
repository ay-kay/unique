

### Abstract

> Recently, Apple removed access to various device hardware identifiers that were frequently misused by iOS third-party apps to track users. We are, therefore, now studying the extent to which users of smartphones can still be uniquely identified simply through their personalized device configurations. Using Apple's iOS as an example, we show how a device fingerprint can be computed using 29 different configuration features. These features can be queried from arbitrary third-party apps via the official SDK. Experimental evaluations based on almost 13,000 fingerprints from approximately 8,000 different real-world devices show that (1) all fingerprints are unique and distinguishable; and (2) utilizing a supervised learning approach allows returning users or their devices to be recognized with a total accuracy of 97% over time.

### Full Paper
Details of our study will be presented at the *Privacy Enhancing Technologies Symposium* 2016 which will be held July 19–22 2016 in Darmstadt, Germany. The full paper will be published in the corresponding *PoPETs journal* 2016 issue 1.

**Preprint:** *Fingerprinting Mobile Devices Using Personalized Configurations.*
Andreas Kurtz, Hugo Gascon, Tobias Becker, Konrad Rieck and Felix Freiling.
Proceedings on Privacy Enhancing Technologies (PoPETS), 2016 (1) , 4–19, to appear 2016. ([PDF](https://www1.cs.fau.de/filepool/projects/unique/unique.pdf))

### Extended Summary

Recently, Apple removed access to various device hardware identifiers that were frequently misused by iOS third-party apps to track users. Therefore, within our latest research project, we are now studying the extent to which users of smartphones can still be uniquely identified simply through their personalized device configurations.

Using Apple’s iOS as an example, we show how a device fingerprint can be computed using 29 different configuration features that can be queried by arbitrary third-party apps via the official SDK. These include, for example, device names, language settings, lists of apps installed and most played songs.

For this purpose, we created our own App Store app “Unique” that collected these features and, if the user gave permission, sent the data to our server for evaluation. Any personally identifiable data was anonymized before transmission using hashing. During our 140-day study period, we collected almost 13,000 data records from 8,000 different real-world devices. All the fingerprints we discovered were unique. Although the fingerprints are clearly distinguishable in theory, it is hard to use them for long-term tracking of users as, in practice, individual fingerprint features change over time when the device is used. This aspect was also investigated, as almost 57% of the data records transmitted to us came from recurring devices.

We then propose a robust solution for measuring the general similarity between any pair of fingerprints, independent of their size and structure. In doing so, we determine an optimal similarity threshold using a supervised learning approach that considers the chronological order in which fingerprints would be received in a real world scenario.

This approach enables us to uniquely identify devices with a total accuracy of 93.76% when all 29 features are included. We then evaluate the collected data from various different perspectives and gradually reduce the feature space to determine features or combinations that would lead to an accuracy increase. Some test cases, for example, use only the list of installed apps or the top 50 most-played songs. Both pieces of information are freely available to third-party apps and querying them is very unobtrusive. Our approach proved capable of uniquely identifying devices purely on the basis of the apps installed, with an overall accuracy of more than 97%. Moreover, identifying devices based solely on the user’s music taste succeeded with a total accuracy of 94.20%.

With regard to user privacy, the main issue with our new approach is that, in most cases, users would be unaware of the data collection taking place and could not prevent it. We also demonstrate that our approach works even with modified configurations, i.e. when individual features are removed by iOS updates or change over time. It should be noted that our method also functions if devices are restored. Whereas Apple’s Advertising Identifiers change after a restore or device replacement, most of the features we use for fingerprinting are restored from backups during the restore process. In this sense, our configuration-based identifier is even stronger than any previous hardware identifiers. As long as a user’s personal profile does not change significantly, he or she can continue to be identified for an indeterminate amount of time.

As a last point, we discuss countermeasures and demonstrate how identification accuracy could be drastically decreased if Apple further tightened the app sandbox to prevent unrestricted access to only a few strong distinguishing features. Some of the countermeasures will already be in place within the upcoming iOS 9. 

### FAQ

 - *Will the dataset of collected fingerprints be made publicly available?*

> We ask for your understanding that we cannot publicly release the dataset as we made a commitment to our study participants to use their data for research purposes and this single experiment only. However, we will shortly release the full source code of our evaluatation and analysis tool to enable other researchers to verify our approach on this basis. At the moment, this repository already contains the sources of our App Store app "Unique" as well as its backend components.

### Contact
For general questions on this research project please contact us at <i1_unique-app@i1.cs.fau.de>.

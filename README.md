# Sensitive Photography - Installation for Festival of Journalism & Art

### Speech to Text & Sentiment Analysis

Using a [Node Red](nodered.org) flow to:
* spawn [sox](http://sox.sourceforge.net/) command, which creates wav from microphone input.
* upload '.wav' to Watson Speech to Text service
* run sentiment analysis on returned text (Node Red uses [npm](https://www.npmjs.com/package/sentiment) library that in turn uses [AFINN-111 wordlist](http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=6010)) 
* dispatch results of sentiment analysis using Open Sound Control (OSC) protocol to listening Processing sketch

### Image Manipuliation

Using Processing to:
* Load and render high resolution image
* Use Fast Fourier Transform (FFT) on microphone input to get rolling average of volume
* Dispatch OSC message to start audio recording 
* Listen on OSC channel for incoming results of sentiment analysis
* Animated image hue to a colour that relates to sentiment score

### Issues encountered

* Inadequacies of Speech to Text when dealing with noisy sound file
* Sentiment analysis is dumbly matching negatively & positively scored words. Does not understand context of sentence. 

# Week 3 Project: Mailbox
_Due:_ Sunday, February 21st at 11:59pm
_Time spent:_ x hrs

## Overview
The purpose of this homework is to leverage views, view properties, and events to create a high fidelity prototype that is difficult to distinguish from a production app. We're going to use the techniques from this week to implement the Carousel app from the signed out state to the basic signed in state.

## Project Requirements

- [x] On dragging the message left...
  - [x] Initially, the revealed background color should be gray.
  - [x] As the reschedule icon is revealed, it should start semi-transparent and become fully opaque. If released at this point, the message should return to its initial position.
  - [x] After 60 pts, the later icon should start moving with the translation and the background should change to yellow.
    - [x] Upon release, the message should continue to reveal the yellow background. When the animation it complete, it should show the reschedule options.
  - [x] After 260 pts, the icon should change to the list icon and the background color should change to brown.
    - [x] Upon release, the message should continue to reveal the brown background. When the animation it complete, it should show the list options.
- [x] User can tap to dismissing the reschedule or list options. After the reschedule or list options are dismissed, you should see the message finish the hide animation.
- [x] On dragging the message right...
  - [x] Initially, the revealed background color should be gray.
  - [x] As the archive icon is revealed, it should start semi-transparent and become fully opaque. If released at this point, the message should return to its initial position.
  - [x] After 60 pts, the archive icon should start moving with the translation and the background should change to green.
    - [x] Upon release, the message should continue to reveal the green background. When the animation it complete, it should hide the message.
  - [x] After 260 pts, the icon should change to the delete icon and the background color should change to red.
    - [x] Upon release, the message should continue to reveal the red background. When the animation it complete, it should hide the message.
- [x] Optional: Panning from the edge should reveal the menu
  - [x] Optional: If the menu is being revealed when the user lifts their finger, it should continue revealing.
  - [x] Optional: If the menu is being hidden when the user lifts their finger, it should continue hiding.
- [ ] Optional: Tapping on compose should animate to reveal the compose view.
- [x] Optional: Tapping the segmented control in the title should swipe views in from the left or right.
- [ ] Optional: Shake to undo.

## GIF

Walkthrough of requirements and optionals:

![Video Walkthrough](gif.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

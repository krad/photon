# photon

[![Build Status](https://travis-ci.org/krad/photon.svg?branch=master)](https://travis-ci.org/krad/photon)

photon is a client for [pupil](https://github.com/krad/pupil)

It acts as a simple means to authenticate with an API server and stream audio / video to pupil.

It's meant to be used by end user applications to simply integrate with the krad.tv stack.

It handles the following responsibilities:

  * User signup & authentication
  * pupil session initialization

Network structures are currently handled using the [grip](https://github.com/krad/grip) library

Media Sources are currently handled using the [kubrick](https://github.com/krad/kubrick) library

In the future these two libraries may become dependencies of photon.

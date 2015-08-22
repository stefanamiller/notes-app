# My Notes App
Notes App built using [RAC 3.0 Release Candidate 1](https://github.com/ReactiveCocoa/ReactiveCocoa/releases/tag/v3.0-RC.1) in Swift

## Xcode Build Notes

- This does not currently build for 32-bit devices due to architecture issues with the Result library. Make sure to run on 64-bit devices only.
- Provisioning is also not setup. To run on a device, configure your provisioning locally and run '[carthage update](https://github.com/Carthage/Carthage)'.


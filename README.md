# iOS-ViewController-Transition-Demo
Update: 更新到了 Swift 3.0，意味着不再支持 iOS 7；依然在使用 Xcode 7 的用户可切换至 Swift 2.2 分支。

[《iOS 视图控制器转场详解》](https://github.com/seedante/iOS-Note/wiki/ViewController-Transition)已发布到微信公众号「iOSDevTips」，这是配套 Demo，使用 Swift 实现。本文并非华丽的转场动画教程，相反，为了不让文章过于复杂和冗长，范例的转场动画效果都是入门级别的。为何弄这么简单的动画效果？转场动画=转场+动画，转场的部分与动画的部分是独立的，无论是简单的转场动画还是复杂的转场动画，他们在转场部分的复杂度几乎是一样的。文章着眼于探索视图控制器转场背后的机制，缺陷以及实现过程中的技巧与陷阱。


###系统内建支持的转场

官方支持的四种转场：

1. UINavigationController 的 push 和 pop，Demo: NavigationControllerTransition，实现了交互控制。
2. UITabBarController 的 Tab 切换，Demo: ScrollTabBarController，实现了交互控制。
3. Modal 转场：presentation 和 dismissal，Demo: CustomModalTransition，当然也支持交互控制，但因为没有合适的交互手段，我在 Demo 里没有为这种转场实现交互控制。
4. UICollectionViewController 布局转场，Demo: CollectionViewControllerLayoutTransition，并非布局转换，而是 CollectionViewController 与 NavigationViewController 结合的转场，不支持交互控制。


###自定义容器控制器转场
唯一算是有点技术含量的 Demo 是 CustomContainerVCTransition，系统并不支持自定义容器控制器的转场，这个话题其实在差不多2年前就有人讨论过， objc.io 在第12期动画专题里实现了[非交互控制的版本](https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/)，并且把实现交互控制留给了读者，不过早已有读者完成了这道作业，依然是国外的开发者。如果你把 [WWDC 2013 Session 218:Custom Transitions Using View Controllers](https://developer.apple.com/videos/play/wwdc2013/218/) 和 [View Controller Programming Guide for iOS](https://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457-CH2-SW1) 看个好几遍，自己再动手把主流的三种模式的转场动画都写一遍，即使是非常简单的动画，并且对协议有点感觉的话，到这个阶段基本上你该知道自定义容器控制器转场该怎么实现了，比较棘手的是交互控制，实际上 objc.io 在更早的 iOS 7专题里对这个话题有所涉及，objc.io 真是个宝库，不过另外一个关键的技术点在 Core Animation 文档里。objc.io 讨论这个话题时 Swift 还没发布，为了避免读者两头跑，我尝试了一个不同的动画效果从头探讨这个话题，如下：

![非交互转场](https://github.com/seedante/iOS-ViewController-Transition-Demo/blob/master/Figures/CustomContainerVCButtonTransition.gif)
![交互转场](https://github.com/seedante/iOS-ViewController-Transition-Demo/blob/master/Figures/ContainerVCTransition.mov.gif)

熟能生巧，转场动画多写几次就知道了整个转场过程，你会发现转场其实蛮简单的，如果不考虑交互控制以及使用第三方的动画控制器，即使实现自定义容器控制器转场十几行代码就可以搞定，在文章里给出了具体代码。转场动画最困难的往往是动画效果本身，这取决于你对动画基础的掌握以及经验。

###iOS 10: 全程可交互的转场动画
上个月的 [WWDC 2016 Session 216: Advances in UIKit Animations and Transitions](https://developer.apple.com/videos/play/wwdc2016/216/) 介绍了全新的交互动画 API，并在 iOS 10 中将其引入了转场协议，之前的转场动画在非交互与交互状态之间有明显的界限：如果以交互转场开始，尽管在交互结束后会切换到非交互状态，但之后无法再次切换到交互状态，只能等待其结束；如果以非交互转场开始，在转场动画结束前是无法切换到交互控制状态的，只能等待其结束。新的交互动画 API 打破了这种界限，使得转场动画全程都可以在这两种状态之间自由切换。

不过，转场协议本身已略显臃肿，iOS 10在此基础上又添加了多个 optional，使得转场协议看上去复杂无比。我实践一番后，发现依靠新的交互动画 API，在实现转场动画可全程在非交互与交互之间自由切换的基础上，可以大幅精简转场协议。

这部分的内容在[《iOS 视图控制器转场详解》](https://github.com/seedante/iOS-Note/wiki/ViewController-Transition)更新，Demo: iOS10PushPop，需要使用 Xcode 8。

全新的交互动画 API 可以用于普通动画的交互。我在 [ControlPanelAnimation](https://github.com/seedante/ControlPanelAnimation) 里演示了如何使用 UIView Animation 和这个新交互动画 API 实现普通动画的交互。
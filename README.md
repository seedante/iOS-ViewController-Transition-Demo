# iOS-ViewController-Transition-Demo

为投稿文章[《iOS 视图控制器转场详解》](https://github.com/seedante/iOS-Note/wiki/ViewController-Transition)写的配套 Demo，基于 Xcode 7 和 Swift 2，包含官方支持的四种方式转场效果：

1. UINavigationController 的 push 和 pop，Demo: NavigationControllerTransition，实现了交互控制。
2. UITabBarController 的 Tab 切换，Demo: ScrollTabBarController，实现了交互控制。
3. Modal 转场：presentation 和 dismissal，Demo: CustomModalTransition，当然也支持交互控制，但因为没有合适的交互手段，我在 Demo 里没有为这种转场实现交互控制。
4. UICollectionViewController 布局转场，Demo: CollectionViewControllerLayoutTransition，并非布局转换，而是 CollectionViewController 与 NavigationViewController 结合的转场，不支持交互控制。

本文并非华丽的转场动画教程，相反，为了不让文章过于复杂和冗长，以上四个范例的动画效果都十分简单，都是入门级别的 Demo。文中的范例动画虽然简单，但内容却不简单，我将带你探索视图控制器转场背后的机制，缺陷以及实现过程中的技巧与陷阱。

当然，还有进阶级别的 Demo：自定义容器控制器转场 CustomContainerVCTransition，而且还实现了交互控制。自定义容器控制转场这个话题其实在差不多2年前就有人讨论过，著名的 objc.io 网站在第12期动画专题里实现了[非交互控制的版本](https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/)，并且把实现交互控制留给了读者，不过早已有读者完成了这道作业，依然是个歪国人，啊，被捷足先登了。如果你把 [WWDC 2013 Session 218:Custom Transitions Using View Controllers](https://developer.apple.com/videos/play/wwdc2013/218/) 和 [View Controller Programming Guide for iOS](https://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457-CH2-SW1) 看个好几遍，自己再动手把主流的三种模式的转场动画都写一遍，即使是非常简单的动画，并且对协议有点感觉的话，到这个阶段基本上你该知道自定义容器控制器转场该怎么实现了，比较棘手的是交互控制，实际上 objc.io 在更早的 iOS 7专题里对这个话题有所涉及，objc.io 真是个宝库，不过另外一个关键的技术点在 Core Animation 文档里，我发现这个过程缺了 google 和 stackoverflow 的话不会那么快。objc.io 讨论这个话题时 Swift 还没发布，为了避免读者两头跑，我尝试了一个不同的动画效果从头探讨这个话题，如下：

![非交互转场](https://github.com/seedante/iOS-ViewController-Transition-Demo/blob/master/Figures/CustomContainerVCButtonTransition.gif)
![交互转场](https://github.com/seedante/iOS-ViewController-Transition-Demo/blob/master/Figures/ContainerVCTransition.mov.gif)

熟能生巧，转场动画多写几次就知道了整个转场过程，你会发现转场其实蛮简单的，实际上自定义容器控制器转场如果不考虑交互控制以及使用第三方的动画控制器，十几行代码就可以搞定，在文章里给出了具体代码。最困难的往往是动画效果本身，因为动画的种类实在是太多了，很多你可能都没见过过自然不知如何实现。

我对本文的定位是成为实现转场动画时的流程参考手册，不过，我还是觉得文章结构有点问题，我会继续修改的。

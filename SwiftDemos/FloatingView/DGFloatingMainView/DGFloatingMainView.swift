//
//  DGFloatingMainView.swift
//  SwiftDemos
//  浮动窗口根视图
//  Created by 开十二 on 2021/3/26.
//

import UIKit

let fixedSpace:CGFloat = 160.0;

class DGFloatingMainView: UIView, UINavigationControllerDelegate {
    
    private static let floatView = DGFloatingMainView(frame: CGRect(x: 10, y: 80, width: 60, height: 60))
    
    private var lastPoint = CGPoint.zero
    
    private var pointInSelf = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.contents = UIImage(named: "FloatingView@2x.png")?.cgImage
        backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    class func showWithView(rootView:UIView) {

        if (floatView.superview == nil) {
            UIApplication.shared.keyWindow?.addSubview(floatView)
            UIApplication.shared.keyWindow?.bringSubviewToFront(floatView)
        }
        
        floatView.addSubview(rootView)
        floatView.frame = CGRect(x: 10, y: UIScreen.main.bounds.height - rootView.frame.size.height - rootView.frame.size.height - 100, width: rootView.frame.size.width, height: rootView.frame.size.height)
        
        currentViewController()?.navigationController?.delegate = floatView
    }
    
    class func remove() {
        floatView.removeFromSuperview()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject()! as! UITouch
        lastPoint = touch.location(in: self.superview)
        pointInSelf = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject()! as! UITouch
        let currentPoint = touch.location(in: self.superview)
        
        //计算当前的中心点
        let centerX = currentPoint.x - (frame.width/2 - pointInSelf.x)
        let centerY = currentPoint.y - (frame.height/2 - pointInSelf.y)
        //修改中心点的坐标
        let x = max(30.0, min(UIScreen.main.bounds.width - 30.0, centerX))
        let y = max(30.0, min(UIScreen.main.bounds.height - 30.0, centerY))

        center = CGPoint(x: x, y: y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject()! as! UITouch
        let currentPoint = touch.location(in: self.superview)
        
        if __CGPointEqualToPoint(lastPoint, currentPoint) {
            /// 点击操作
            distanceLeftOrRightMarginNeedAnimationMove(isAnimation: false)
            if let nav = DGFloatingMainView.currentViewController()?.navigationController {
                print("存在导航控制器 push 跳转\(nav)")
            } else {
                print("没有导航栏 model 跳转")
            }
            return
        }
        
        //动画收缩
        UIView.animate(withDuration: 0.25) {
            /// 如果floatingView在semiCircleView内部，就移除
            /// 计算2个圆心的距离
            let distance = CGFloat(sqrt(powf(Float(UIScreen.main.bounds.width - self.center.x), 2)+powf(Float(UIScreen.main.bounds.height-self.center.y), 2)))

            if distance <= fixedSpace - 30 {
                DGFloatingMainView.remove()
            }
        }
        
        
        distanceLeftOrRightMarginNeedAnimationMove(isAnimation: true)
    }
    
    ///计算左右的距离并且是否需要动画移动
    private func distanceLeftOrRightMarginNeedAnimationMove(isAnimation: Bool) {
        
        let duartion = isAnimation ? 0.25:0
        
        let leftMargin = center.x
        let rightMargin = UIScreen.main.bounds.width - leftMargin
        
        let centerX = leftMargin < rightMargin ? 40.0 : UIScreen.main.bounds.width - 40.0
        
        UIView.animate(withDuration: duartion) {
            self.center = CGPoint(x: centerX, y: self.center.y)
        }
    }
}



extension DGFloatingMainView  {
    
    /// 获取根视图控制器
    /// - Returns: <#description#>
    static func currentViewController() -> UIViewController? {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        
        guard var rootVC = vc else { return nil }
        
        while true {
            if rootVC.isKind(of: UITabBarController.self)  {
                rootVC = (rootVC as! UITabBarController).selectedViewController!
            }
            
            if rootVC.isKind(of: UINavigationController.self) {
                rootVC = (rootVC as! UINavigationController).visibleViewController!
            }
            
            if (rootVC.presentingViewController != nil) {
                rootVC = rootVC.presentingViewController!
            } else {
                break;
            }
        }
        return rootVC
    }

}



    
    

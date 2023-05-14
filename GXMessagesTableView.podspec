#
#  Be sure to run `pod spec lint GXMessagesTableView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name          = "GXMessagesTableView"
  s.version       = "1.0.7"
  s.swift_version = ["4.2", "5.0"]
  s.summary       = "一个实现Telegram会话头像底部悬停(左右头像都可以悬停)以及header悬停显示效果，并且实现下滑加载的TableView。"
  s.homepage      = "https://github.com/gsyhei/GXMessagesTableView"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Gin" => "279694479@qq.com" }
  s.platform      = :ios, "11.0"
  s.source        = { :git => "https://github.com/gsyhei/GXMessagesTableView.git", :tag => "1.0.7" }
  s.requires_arc  = true
  s.source_files  = "GXMessagesTableView"
  s.frameworks    = "Foundation","UIKit"
  s.dependency  'GXCategories'
  s.dependency  'GXRefresh'

end

source 'https://cdn.cocoapods.org/'
install! 'cocoapods', :generate_multiple_pod_projects => true
inhibit_all_warnings!
platform :osx, '11.0'
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

target 'uPic' do
    pod "libminipng"
    pod 'WCDB.swift'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '11.0'
               end
          end
   end
end

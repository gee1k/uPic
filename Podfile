source 'https://cdn.cocoapods.org/'
install! 'cocoapods', :generate_multiple_pod_projects => true
inhibit_all_warnings!
platform :osx, '10.15'
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

target 'uPic' do
    pod "libminipng"
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15'
               end
          end
   end
end

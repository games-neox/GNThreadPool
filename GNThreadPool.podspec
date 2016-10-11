#
#  Created by Games Neox - 2016
#  Copyright © 2016 Games Neox. All rights reserved.
#

Pod::Spec.new do |s|
s.name                  = 'GNThreadPool'
s.version               = '0.4.0'
s.summary               = 'thread pool for Objective-C'

s.homepage              = 'https://github.com/games-neox/GNThreadPool'
s.license               = { :type => 'MIT', :file => 'LICENSE' }
s.author                = { 'Games Neox' => 'games.neox@gmail.com' }
s.source                = { :git => 'https://github.com/games-neox/GNThreadPool.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'

s.dependency 'GNExceptions'
s.dependency 'GNLog'
s.dependency 'GNPreconditions'

s.source_files          = 'GNThreadPool/Classes/*'

s.public_header_files   = 'GNThreadPool/Classes/*.h'
end

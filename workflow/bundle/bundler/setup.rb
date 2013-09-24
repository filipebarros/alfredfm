gempath = File.expand_path('../../gems', __FILE__)
File.exist?(gempath) or raise "Gem path #{gempath} not found."

$LOAD_PATH.unshift File.join(gempath, 'i18n-0.6.5', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'minitest-4.7.5', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'multi_json-1.8.0', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'atomic-1.1.12', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'thread_safe-0.1.2', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'tzinfo-0.3.37', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'plist-3.1.0', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'alfred-workflow-1.8.0', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'multi_xml-0.5.5', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'httparty-0.11.0', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'xml-simple-1.1.2', 'lib')
$LOAD_PATH.unshift File.join(gempath, 'lastfm-1.20.1', 'lib')

if RUBY_VERSION.to_f < 1.9 # OS X 10.8 and below system Ruby support
  $LOAD_PATH.unshift File.join(gempath, 'uuidtools-2.1.4', 'lib')
  $LOAD_PATH.unshift File.join(gempath, 'activesupport-3.2.14', 'lib')
else
  $LOAD_PATH.unshift File.join(gempath, 'activesupport-4.0.0', 'lib')
end

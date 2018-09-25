log_level                :info
log_location             STDOUT
node_name                'dswain'
editor                   'vim'
# client_key               File.join(File.dirname(__FILE__), 'dswain.pem')
validation_client_name   'chef-validator'
# validation_key           File.join(File.dirname(__FILE__), 'validation.pem')
cookbook_path            File.join(File.dirname(__FILE__), '..', 'cookbooks')
chef_server_url          'http://dctest1.simpli.fi:4000'
cookbook_copyright       'Simpli.fi'
cookbook_email           'dan@simpli.fi'
cache_type               'BasicFile'
cache_options( :path => 'checksums' )

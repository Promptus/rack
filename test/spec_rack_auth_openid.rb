require 'test/spec'

# requires the ruby-openid gem
require 'rack/auth/openid'

context "Rack::Auth::OpenID" do
  OID = Rack::Auth::OpenID
  realm = 'http://path/arf'
  ruri = %w{arf arf/blargh}
  auri = ruri.map{|u|'/'+u}
  furi = auri.map{|u|'http://path'+u}

  specify 'realm uri should be absolute and have a path' do
    lambda{OID.new('/path')}.
      should.raise ArgumentError
    lambda{OID.new('http://path')}.
      should.raise ArgumentError
    lambda{OID.new('http://path/')}.
      should.not.raise
    lambda{OID.new('http://path/arf')}.
      should.not.raise
  end

  specify 'uri options should be absolute' do
    [:login_good, :login_fail, :login_quit, :return_to].each do |param|
      ruri.each do |uri|
        lambda{OID.new(realm, {param=>uri})}.
          should.raise ArgumentError
      end
      auri.each do |uri|
        lambda{OID.new(realm, {param=>uri})}.
          should.raise ArgumentError
      end
      furi.each do |uri|
        lambda{OID.new(realm, {param=>uri})}.
          should.not.raise
      end
    end
  end

  specify 'return_to should be absolute and be under the realm' do
    lambda{OID.new(realm, {:return_to => 'http://path'})}.
      should.raise ArgumentError
    lambda{OID.new(realm, {:return_to => 'http://path/'})}.
      should.raise ArgumentError
    lambda{OID.new(realm, {:return_to => 'http://path/arf'})}.
      should.not.raise
    lambda{OID.new(realm, {:return_to => 'http://path/arf/'})}.
      should.not.raise
    lambda{OID.new(realm, {:return_to => 'http://path/arf/blargh'})}.
      should.not.raise
  end

  specify 'extensions should be a module' do
    ext = Object.new
    lambda{OID.new(realm).add_extension(ext)}.should.raise TypeError
    ext2 = Module.new
    lambda{OID.new(realm).add_extension(ext2)}.should.raise ArgumentError
  end

  specify 'extensions should have required constants defined' do
    ext = Module.new
    lambda{OID.new(realm).add_extension(ext)}.should.raise ArgumentError
    ext::Request = nil
    lambda{OID.new(realm).add_extension(ext)}.should.raise ArgumentError
    ext::Response = nil
    lambda{OID.new(realm).add_extension(ext)}.should.raise ArgumentError
    ext::NS_URI = nil
    lambda{OID.new(realm).add_extension(ext)}.should.raise TypeError
  end

  specify 'extensions should have Request and Response defined and inherit from OpenID::Extension' do
    ext = Module.new
    ext::Request = nil
    ext::Response = nil
    ext::NS_URI = nil
    lambda{OID.new(realm).add_extension(ext)}.should.raise TypeError
    ext::Request = Class.new(::OpenID::Extension)
    lambda{OID.new(realm).add_extension(ext)}.should.raise TypeError
    ext::Response = Class.new(::OpenID::Extension)
    lambda{OID.new(realm).add_extension(ext)}.should.raise TypeError
  end

  specify 'extensions should have NS_URI defined and be a string of an absolute http uri' do
    ext = Module.new
    ext::Request = Class.new(::OpenID::Extension)
    ext::Response = Class.new(::OpenID::Extension)
    ext::NS_URI = nil
    lambda{OID.new(realm).add_extension(ext)}.should.raise TypeError
    ext::NS_URI = 'openid.net'
    lambda{OID.new(realm).add_extension(ext)}.should.raise ArgumentError
    ext::NS_URI = 'http://openid.net'
    lambda{OID.new(realm).add_extension(ext)}.should.not.raise
  end
end

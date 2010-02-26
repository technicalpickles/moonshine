require 'test_helper'

class Moonshine::Manifest::ApacheTest < Test::Unit::TestCase
  def setup
    @manifest = Moonshine::Manifest::Rails.new
  end

  def test_default_keepalive_off
    @manifest.apache_server

    assert_kind_of Hash, @manifest.configuration[:apache]
    assert_equal 'Off', @manifest.configuration[:apache][:keep_alive]


    apache2_conf_content = @manifest.files['/etc/apache2/apache2.conf'].content
    assert_apache_directive apache2_conf_content, 'KeepAlive', 'Off'
  end

  def test_override_keepalive_on_early
    @manifest.configure :apache => { :keep_alive => 'On' }
    @manifest.apache_server

    assert_kind_of Hash, @manifest.configuration[:apache]
    assert_equal 'On', @manifest.configuration[:apache][:keep_alive]

    apache2_conf_content = @manifest.files['/etc/apache2/apache2.conf'].content
    assert_apache_directive apache2_conf_content,  'KeepAlive', 'On'
  end

  def test_override_keepalive_on_late
    @manifest.apache_server
    @manifest.configure :apache => { :keep_alive => 'On' }

    assert_kind_of Hash, @manifest.configuration[:apache]
    assert_equal 'On', @manifest.configuration[:apache][:keep_alive]
    assert_apache_directive @manifest.files['/etc/apache2/apache2.conf'].content, 'KeepAlive', 'On'
  end

  def test_installs_apache
    @manifest.apache_server

    assert_not_nil apache = @manifest.services["apache2"]
    assert_equal @manifest.package('apache2-mpm-worker').to_s, apache.require.to_s
  end

  def test_enables_mod_ssl_if_ssl
    @manifest.configure(:ssl => {
      :certificate_file => 'cert_file',
      :certificate_key_file => 'cert_key_file',
      :certificate_chain_file => 'cert_chain_file'
    })

    @manifest.apache_server

    assert_not_nil @manifest.execs.find { |n, r| r.command == '/usr/sbin/a2enmod ssl' }
  end

  def test_enables_mod_rewrite
    @manifest.apache_server

    assert_not_nil apache = @manifest.execs["a2enmod rewrite"]
  end

  def test_enables_mod_status
    @manifest.apache_server

    assert_not_nil apache = @manifest.execs["a2enmod status"]
    assert_match /127.0.0.1/, @manifest.files["/etc/apache2/mods-available/status.conf"].content
  end
end

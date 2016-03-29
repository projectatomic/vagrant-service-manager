# OS Module
module OS
  def self.windows?
    (/mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def self.windows_cygwin?
    (/cygwin/ =~ ENV["VAGRANT_DETECTED_OS"]) != nil
  end

  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def self.unix?
    !windows?
  end

  def self.linux?
    unix? && !mac?
  end
end

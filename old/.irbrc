#require "rubygems"
#require "wirble"
#Wirble.init
#Wirble.colorize

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:LOAD_MODULES] = [] unless IRB.conf.key?(:LOAD_MODULES)
unless IRB.conf[:LOAD_MODULES].include?('irb/completion')
	IRB.conf[:LOAD_MODULES] << 'irb/completion'
end

class Object
  # Return only the methods not present on basic objects
  def m
    (self.methods - Object.new.methods).sort
  end

  def msearch term
    m.keep_if{|m| m.to_s.include? term }
  end

  def pp
    PP.pp self
  end
end

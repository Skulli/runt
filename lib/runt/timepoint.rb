#!/usr/bin/env ruby

require 'date'
require 'runt'

=begin
  TimePoint - based the pattern by Martin Fowler
	See: http://martinfowler.com/ap2/timePoint.html
  Author: Matthew Lipper
=end

class Date
	
	include Runt

	attr_accessor :date_precision
  
	class << self

  	alias_method :old_civil, :civil

		def civil(*args)		
			if(args[0].instance_of?(Runt::DatePrecision::Precision))
				precision = args.shift
			else
				return Runt::DatePrecision.day_of_month(*args)
				#precision = nil
			end
			_civil = old_civil(*args)
			_civil.date_precision = precision
			_civil
		end
	end
	
	class << self; alias_method :new, :civil end

	def + (n)
		raise TypeError, 'expected numeric' unless n.kind_of?(Numeric) 
		
		if(leap?) 
			days_in_year = 365
		else
			days_in_year = 366
		end
		
		case @date_precision
			when Runt::DatePrecision::YEAR then 
				return new_self_plus(n){ |n| n = n*days_in_year }	
			when Runt::DatePrecision::MONTH then 
				return new_self_plus(n){ |n| n = (n*(days_in_year/12).to_i)} 
			#Default behaviour already in Date
			when Runt::DatePrecision::DAY_OF_MONTH then 
				return new_self_plus(n){ |n| n = n }			
		end
	end
	
	private

	def new_self_plus(n)		
		if(block_given?)
			n=yield(n) 
		end
		
		return Runt::DatePrecision::to_p(self.class.new0(@ajd + n, @of, @sg),@date_precision)
	end
end

class DateTime

	attr_accessor :date_precision
	class << self

#		alias_method :civil, :new 
  	alias_method :old_civil, :civil

		def civil(*args)
			if(args[0].instance_of?(Runt::DatePrecision::Precision))
				precision = args.shift
			else
				return Runt::DatePrecision.minute(*args)			
				#precision = nil
			end
		_civil = old_civil(*args)
		_civil.date_precision = precision
		_civil
		end
	end
		
	class << self; alias_method :new, :civil end
	
	def + (n)
		raise TypeError, 'expected numeric' unless n.kind_of?(Numeric) 
		case @date_precision
			when Runt::DatePrecision::HOUR_OF_DAY then n = (n*(1.to_r/24) )			
			when Runt::DatePrecision::MINUTE then n = (n*(1.to_r/1440) )		
			when Runt::DatePrecision::SECOND then n = (n*(1.to_r/86400) )
		end
		return self.class.new0(@ajd + n, @of, @sg)
	end

end

module Runt
			
		class TimePoint < DateTime
		
			include DatePrecision

			attr_reader :date_precision
			
			def initialize(*args)
				super(*args)
			end
			
		end
end
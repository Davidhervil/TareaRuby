require 'singleton'

class Interval
	attr_reader :izq, :der, :izq_in, :der_in
	# Verificar si es mejor hacer las inclusiones con un numero
	# y sumarselo siempre CHECKED-RECHECKED
	def initialize izq, der, izq_in=true, der_in=true
		
		#OJO ARREGLAR
		if empt?(izq,der,izq_in,der_in)
			puts "what"
			Empty.instance
		elsif izq == -(Float::INFINITY) && der == Float::INFINITY
			AllReals.instance
		elsif izq == -(Float::INFINITY)
			LeftInfinite.new(der,der_in)
		elsif der == Float::INFINITY
			RightInfinite.new(izq,izq_in)
		else
			Literal.new(@izq,@der,@izq_in,@der_in)
		end
	end

	def to_s
		if self.empty?
			"Vacio"
		else
			if self.izq_in == true
				l='['
			else
				l='('
			end
			if self.der_in == true
				d = ']'
			else
				d = ')'
			end
			l + self.izq.to_s + ',' + self.der.to_s + d
		end
	end

	def empty?
		self == Empty.instance
	end

	def empt? i, d, izn, den
		i>d || ( i == d && ( ((false == izn )== den) || ( izn != den )))
	end

	private :empt?
end

class Literal < Interval
	def initialize izq, der, izq_in = true, der_in = true
		@izq = izq
		@der = der
		@izq_in = izq_in
		@der_in = der_in
	end
end

class RightInfinite < Interval
	def initialize izq, izq_in = true
		@izq = izq
		@der = Float::INFINITY
		@der_in = false
		@izq_in = izq_in
	end
end

class LeftInfinite < Interval
	def initialize der, der_in = true
		@der = der
		@izq = -(Float::INFINITY)
		@izq_in = false
		@der_in = der_in
	end
end

class AllReals < Interval
	include Singleton
	def initialize
		@izq = -(Float::INFINITY)
		@der = Float::INFINITY
		@izq_in = false
		@der_in = false
	end
end

class Empty < Interval
	include Singleton
	def initialize
	end
end

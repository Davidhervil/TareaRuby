
module Fold
    def null?
        self.foldr(true) {|a| false}
    end
    
    def foldr1 &block
        #meterse un paso en la recursioon
        if not self.null?
            self.foldr(nil)&block)
        else
            raise "Estructura vacia"
        end 
    end

    def length
        self.foldr(0) {|e,ac| ac + 1}
    end

    def all? &block
        self.foldr(true) {|e,ac| ac && block.call(e)}
    end

    def any? &block
        self.foldr(false) {|e,ac| ac || block.call(e)}
    end 
    
    def to_arr
        self.foldr([]) {|e,ac| ac.unshift(e)}
    end

    def elem? to_find
        self.foldr(false) {|e,ac| ac || e==to_find }
    end

end
class Array
    include Fold
    def foldr e, &b 
        #reverse.inject(e) { |acum,elem| elem.send(b,acum)}
        #Otra posible opcion es invertir el arreglo y hacerle fold norml con un ciclo.
        n = self.length
        if n>=1
            b.call(self.first,self.last(n-1).foldr(e,&b))
        else
            e
        end
    end
end

class Rose
    include Fold
    attr_accessor :elem, :children
    def initialize elem, children = []
        @elem = elem
        @children = children
    end
    def add elem
        @children.push elem
        self
    end
    def foldr e, &b
        # Su código aquí
        acum = e
        if self.children.length >= 1
            i=self.children.size - 1
            while i>=0
                acum = self.children[i].foldr(acum,&b)
                i -= 1
            end
        end

        b.call(self.elem, acum)
    end

    def avg
        self.foldr1
    end

end

def main
    a = Rose.new(1, [Rose.new(2, [ Rose.new(4), Rose.new(5) ]),Rose.new(3, [ Rose.new(6) ])])
    a.foldr(0) {|m,e|m+e}
end
a = Rose.new(1, [Rose.new(2, [ Rose.new(4), Rose.new(5) ]),Rose.new(3, [ Rose.new(6) ])])
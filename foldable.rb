
class Array
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

"""
class Array
    
    def foldr e, &block
        acum = e
        i = self.size
        while i > 0
            i -= 1
            acum = block.call(self[i],acum)
        end
        return acum
    end

end
"""
class Rose
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
end

def main
    a = Rose.new(1, [Rose.new(2, [ Rose.new(4), Rose.new(5) ]),Rose.new(3, [ Rose.new(6) ])])
    a.foldr(0) {|m,e|m+e}
end

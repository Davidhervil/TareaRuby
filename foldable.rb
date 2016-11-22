module Fold
    def null?
        self.foldr(true) {|a| false}
    end

    def foldr1 &block
        if not self.null?
            self.foldr(nil) {|e,ac| ac ? block.call(e,ac) : e}
        else
            raise "Estructura vacia"
        end
    end
    def length
        self.foldr(0) { |e,ac| ac+1 }
    end
    def all? &block
        self.foldr(true) { |e,ac| ac && block.call(e)}
    end
    def any? &block
        self.foldr(false) { |e,ac| ac || block.call(e)}
    end
    def to_arr
        self.foldr([]) { |e,ac| ac.unshift(e)}
    end
    def elem? to_find
        self.foldr(false) { |e,ac| ac || e == to_find}
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
        b=[0,1]
        self.foldr1 {|e,a| b[1]+=1; b[0]= a+e}
        suma = b[0]
        total = b[1]
        Float(suma)/total
    end
end

def main
    a = Rose.new(1, [Rose.new(2, [ Rose.new(4), Rose.new(5) ]),Rose.new(3, [ Rose.new(6) ])])
    b = [1,2,3,4,5,6]
    c = []
    puts a.foldr1 {|e,ac| e+ac} 
    puts " Suma arbol"
    puts b.foldr1 {|e,ac| e+ac} 
    puts " Suma areglo"
    puts a.null? 
    puts " Arbol null"
    puts b.null? 
    puts " Arreglo no vacio null"
    puts c.null? 
    puts " Arreglo vacio null"
    puts a.all? { |e| e>=1 } 
    puts " Arbol all true"
    puts a.all? { |e| e<1 } 
    puts " Arbol all false"
    puts b.all? { |e| e>=1 } 
    puts " Arreglo all true"
    puts b.all? { |e| e<1 } 
    puts " Arreglo all false"
    puts a.any? { |e| e==1 } 
    puts " Arbol any true"
    puts a.any? { |e| e<1 } 
    puts " Arbol any false"
    puts b.any? { |e| e==1 } 
    puts " Arreglo any true"
    puts b.any? { |e| e<1 } 
    puts " Arreglo any false"
    puts a.length #OJO WTF ESTE NO FUNCIONA
    puts " Arbol longitud"
    puts b.length 
    puts " Arreglo longitud"
    puts a.to_arr 
    puts " Arbol arreglo"
    puts b.to_arr 
    puts " Arreglo^2"
    puts a.elem? 3
    puts " Arbol busqueda true"
    puts b.elem? 3
    puts " Arreglo busqueda true"
    puts a.elem? 69 
    puts " Arbol busqueda false"
    puts b.elem? 69 
    puts " Arreglo busqueda false"
    return "Readixon"
end

# TODO: rewrite in a better and more julian way.
#
# This is just kind of thrown together without any real planning but it seems to
# work. An obviouse design improvement would be to drop the string identifiers
# and use types or something instead. Conssider this as a functional outline for
# a future product.
s = raw"""
@blue:#5555ff

.round-button{
    display:inline-block; margin:7; radius:12; color: @blue;
    hover{color: @blue; }
    circle{ radius:12;}
}

circle{ class:round-button; circle{ image:"Back.png"} }
"""

mutable struct Vars
    name::String
    Vars(name) = new(name)
end
# include("Documents/code/parseScss.jl")
#-==============================================================================
# Tokenize Sml text
#-==============================================================================
function tokens(s)
	toks = []
from,i = 1,1
while i < length(s)
    from = i
        if s[from] == '/'
    # Comment-------------------------
            if s[i+1] == '*'
                i+=1
                while !(s[i] == '/' && s[i-1] == '*')
                    i+=1
                end
				push!(toks, ["Comment", s[from:i]])
    # Comment-------------------------
            elseif s[i+1] == '/'
	              i+=1
                while s[i+1] != '\n'
                    i+=1
                end
				push!(toks, ["Comment", s[from:i]])
    # Divide-------------------------
            else
				push!(toks, ["Math", s[from:i]])
            end
    # Var-------------------------
		elseif s[from] == '@'
            i+=1
            while isletter(s[i+1]) || s[i+1] == '-'
                i+=1
            end
			push!(toks, ["Vars", Vars(s[from+1:i])])
	# Text-------------------------
		elseif s[from] == '"'
			if s[i+1] == '"' &&  s[i+2] == '"'
				i+=3
				while !(s[i] == '"' && s[i-1] == '"' && s[i-2] == '"' && s[i-3] != '\\')
					 i+=1
				end
				push!(toks, ["Text", s[from:i]])
			else
			     i+=1
			     while s[i] != '"' && !(s[i-1] == '\\' && s[i] == '"')
			          i+=1
			     end
				 push!(toks, ["Text", s[from:i]])
		 	end
    # Identifier-------------------------
        elseif isletter(s[from])
            i+=1
            while isletter(s[i+1]) || s[i+1] == '-'
            i+=1
        end
		push!(toks, ["Identifier", s[from:i]])
    # Class-------------------------
        elseif s[from] == '.'
            i+=1
            while isletter(s[i+1]) || s[i+1] == '-'
                i+=1
            end
		push!(toks, ["Class", s[from+1:i]])
	# Number------------------------
		elseif s[from] == '-' || isdigit(s[i]) || s[i] == '.'
	    	while isdigit(s[i+1]) || s[i+1] == '.'
		        i+=1
	        end
			push!(toks, ["Number", parse(Float64, s[from:i])])
			if s[i+1] == '%'
				i+=1
				push!(toks, ["Unit", s[i]])
			end
	# Math------------------------
	        elseif s[from] == '+' || s[i] == '-' || s[i] == '/' || s[i] == '*' || s[i] == '%'
				push!(toks, ["Math", s[i]])
    # Hex-------------------------
        elseif s[from] == '#'
            i+=1
            while isdigit(s[i+1]) || 'a' <= s[i+1] <= 'f'
                i+=1
            end
			push!(toks, ["Hex", s[from:i]])
    # Space-------------------------
        elseif s[from] == ' ' || s[i] == '\t'
            while s[i+1] == ' ' || s[i+1] == '\t'
                i+=1
            end
			push!(toks, ["Space", s[from:i]])
    # Comma-------------------------
        elseif s[from] == ','
			push!(toks, ["Comma", s[i]])
    # Instance-------------------------
        elseif s[from] == ':'
			push!(toks, ["Instance", s[i]])
    # OpenBl-------------------------
        elseif s[from] == '{'
			push!(toks, ["OpenBl", s[i]])
    # CloseBl-------------------------
        elseif s[from] == '}'
			push!(toks, ["CloseBl", s[i]])
    # EndLine-------------------------
        elseif s[from] == '\n' ||  s[i] == ';'
			push!(toks, ["EndLine", s[i]])
    # CatchAll-------------------------
        else
             println("CatchAll" * s[i])
        end
    i+=1
  end
  return toks
end
#-==============================================================================
# "Class" "Identifier" "Vars" "Comment" "Comma" "Instance"  "OpenBl" "CloseBl"
#-==============================================================================
function crunch(toks)
	stack = []
	push!(toks, ["EndLine",';'], ["EndLine",';']);

# Remove whitspace and other nodes
push!(stack, toks[1])
	for t in 2:length(toks)
		if  !((toks[t][1] == "EndLine" && toks[t-1][1] == "EndLine") || toks[t][1] == "Space" || toks[t][1] == "Comma" || toks[t][1] == "Comment")
		   push!(stack, toks[t])
		end
	end

	# find Attributes
	toks = stack
	stack = []
	t=1
	push!(toks, ["telemer",';'],["telemer",';'],["telemer",';'],["telemer",';'],["telemer",';']);
	while t < length(toks)
		if  toks[t][1] == "Identifier" && toks[t+1][1] == "Instance"
			toks[t][1] = "Attribute"
			push!(stack, toks[t])
			t+=2
		else
			push!(stack, toks[t])
			t+=1
		end
	end

	# Make numbers
	toks = stack
	stack = []
	t=1
	while t <= length(toks)
		if  toks[t][1] == "Number" && (toks[t+1][1] == "Identifier" || toks[t+1][1] == "Unit") # Unit
			push!(stack, ["Identifier", [toks[t][2], toks[t+1][2]]])
			t+=2
		else
			push!(stack, toks[t])
			t+=1
		end
	end

	# Make Arrays      {[\n\s]+}    [^{}]+
	# Hex Number Text Var Identifier
	toks = stack
	stack = []
	t=1
	while t < length(toks)
		b, c = toks[t][1], toks[t+1][1]
		if (b == "Hex" || b == "Number" || b == "Text" || b == "Vars" || b == "Identifier") && (c == "Hex" || c == "Number" || c == "Text" || c == "Vars" || c == "Identifier")
			a = [toks[t][2], toks[t+1][2]]
			t+=2
			while t < length(toks) && (toks[t][1] == "Hex" || toks[t][1] == "Number" || toks[t][1] == "Text" || toks[t][1] == "Vars" || toks[t][1] == "Identifier")
				push!(a, toks[t][2])
				t+=1
			end
			push!(stack, ["Identifier", a])
		else
			push!(stack, toks[t])
			t+=1
		end
	end


t = stack
push!(t, ["EndLine",';'], ["EndLine",';'], ["EndLine",';']);

stack = []
i=1
	while i < length(t)-3
		one, two, three, four = t[i],t[i+1],t[i+2],t[i+3]
		if  one[1] == "Vars" && two[1] == "Instance"
			if three[1] == "Identifier" || three[1] == "Hex" || three[1] == "Vars"
				push!(stack, [one[1], one[2], "Identifier", three[2]])
				i+=3
			end
		# Attribute
		elseif  one[1] == "Attribute" #&& two[1] == "Identifier"
			if two[1] == "Vars" || two[1] == "Text" || two[1] == "Hex" || two[1] == "Identifier" || two[1] == "Number"
				push!(stack, [one[1], one[2], two[1], two[2]])
			i+=2
			end
		elseif  one[1] == "CloseBl"
			push!(stack, one)
			i+=1
		elseif  one[1] == "EndLine" || one[1] == "Space"
			i+=1
		elseif  one[1] == "Identifier" && two[1] == "OpenBl"
			one[1] = "Tag"
			push!(stack, one)
			push!(stack, two)
			i+=2
		else
			push!(stack, one)
			i+=1
		end
	end

	return stack
end
#-==============================================================================
# EndLine CloseBl OpenBl Instance Comma Space Hex Math Unit Number Class Identifier Text Vars Comment
# Identifier
# Text Hex Math
# Class Vars Tag
#-==============================================================================

#-==================================OUTLINE=====================================
#                                               # structure, content, styles
# element: ["div", Dict(atributes), []]         #    yes       yes     yes
# variable: ["MyTemplate", Dict(atributes), []] #    yes     default   yes
# variable: ["Mycolor", Value]                  # ---- just store a value ----
# class: ["div", Dict(atributes), []]           #    no        no      yes
#-==============================================================================
#  [ element/variable/class(name: , Dict(atributes), []) ]
function nest(toks)
	this = Dict("styles"=>Dict(), "templates"=>Dict(), "nodes"=>[])
	t = 1

	function element(toks, named=true)
		name = toks[t][2]
		node = Dict()
		node["nodes"] = []
		# Dict( ">"=>"div", "height"=>value(39), "nodes"=>[] )
		t+=1  #["Vars", "template", []] & ["OpenBl", '{']
			while toks[t][1] != "CloseBl"
				if toks[t+1][1] == "OpenBl"
					push!(node["nodes"], element(toks))
				elseif toks[t][1] == "Identifier" || toks[t][1] == "Text"
					println(toks[t])
				elseif toks[t][1] == "Attribute" || toks[t][1] == "Text"
					node[toks[t][2]] = toks[t][4]
				elseif toks[t][1] == "OpenBl"
					;
				else
					println("Error!", toks[t])
				end
				t+=1
			end
			if named==true
				node[">"] = name
			end
				return node #
	end

	while t < length(toks)
		if toks[t][1] == "Vars"
			if toks[t+1][1] == "OpenBl"  #["Vars", "template", []] ["OpenBl", '{']
				push!(this["templates"], toks[t][2] => element(toks, false))
			else
				push!(this["templates"], toks[t][2] => toks[t][4]) # Plain vanilla Variable
			end
		elseif toks[t][1] == "Tag"
			push!(this["nodes"], element(toks))
		elseif toks[t][1] == "Class"
			push!(this["styles"], toks[t][2] => element(toks, false))
			println(this["styles"])
		else
			# println(toks[t])
		end
		t+=1
	end
	return this
end

function readSml(text)
	return nest( crunch(tokens(text)) )
end

function writeSml(text)
	result = " "
	# TODO: write code!
	return result
end


function addAttributes(node, style)  classname, stylesDict

		attrs = collect(keys(style))
		for a in attrs
			if a == "nodes"
				for n in node["nodes"]
					for st in style["nodes"]
						if n[">"] == st[">"]
							addAttributes(n, st)
						end
					end
				end
			elseif !haskey(node, a) && a != ">"
				node[a] = style[a]
			end
		end
end


function compile(nodes)
	for st in nodes
		if haskey(st, "class")
			# WARNING: class could be an array!
			# println(st["class"])
			if haskey(text["styles"], st["class"])
				style = text["styles"][st["class"]]
				addAttributes(st, style)
			end
		end
		if length(st["nodes"]) > 0
			compile(st["nodes"])
			println("has kids!")
		end
	end
end

text = readSml(s)
text["styles"]
compile(text["nodes"])

print(text["nodes"])



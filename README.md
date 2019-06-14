# SML
Scss-like markup language. It's clean, terse and expressive!

Let's compare Json and SML.

## Here's the SML
```scss
.round-button{
    display:inline-block; margin:7; radius:12; color: 0.6 0.6 0.6
    hover{color: 0.8 0.8 0.8; }
    circle{ radius:12;}
}

div{  height:39;  color: 0.6 0.6 0.6; padding:2;
    circle{ class:round-button; circle{ image:"Back.png"} }            
    circle{ class:round-button; circle{ image:"Reload.png"} }            
    circle{ class:round-button; circle{ image:"Forward.png"} }            
    circle{ class:round-button; circle{ image:"Start.png"} }            
    circle{ class:round-button; float:right; circle{ image:"Download.png"} }            

    div{ marked:true; display:inline-block; height:22; padding:3 4 3 3; margin:4 4 4 4; color:0.9 0.9 0.9
        border{radius:3 3 3 3; width:thin; style:solid; color:0.3 0.3 0.3 }
                     
        div{ margin:3 3 3 3; display:inline-block; width:15; height:15; 
            image:"Search.png"; color:lightgreen}
        div{display:inline; text:"file:///src/SamplePages/test.json"
            font{color:black; size:15; lineHeight:1.4; family:sans} 
        }                     
    }
}

```

## Now let's compare with equivalent JSON:
```json
{">":"div",  "height":39, "color":[0.6,0.6,0.6], "padding":2,
    "nodes":[
        {">":"circle", "display":"inline-block", "margin":7, "radius":12, "color":[0.6,0.6,0.6],
            "hover":{"color":[0.8,0.8,0.8] },
            "nodes":[{">":"circle", "radius":12, "image":"Back.png"}]},
        {">":"circle", "display":"inline-block", "margin":7, "radius":12, "color":[0.6,0.6,0.6],
            "hover":{"color":[0.8,0.8,0.8] },
            "nodes":[{">":"circle", "radius":12, "image":"Reload.png"}]},
        {">":"circle", "display":"inline-block", "margin":7, "radius":12, "color":[0.6,0.6,0.6],
             "hover":{"color":[0.8,0.8,0.8] },
             "nodes":[{">":"circle", "radius":12, "image":"Forward.png"}]},
        {">":"circle", "display":"inline-block", "margin":7, "radius":12, "color":[0.6,0.6,0.6],
            "hover":{"color":[0.8,0.8,0.8] },
            "nodes":[{">":"circle", "radius":12, "image":"Start.png"}]},
        {">":"circle", "display":"inline-block", "margin":7, "radius":12, "color":[0.6,0.6,0.6], "float":"right",
                "hover":{"color":[0.8,0.8,0.8] },
                "nodes":[{">":"circle", "radius":12, "image":"Download.png"}]},

                {">":"div", "marked":true, "display":"inline-block", "height":22, "padding":[3,4,3,3], "margin":[4,4,4,4], "color":[0.9,0.9,0.9],
                "border":{"radius":[3,3,3,3], "width":"thin", "style":"solid", "color":[0.3,0.3,0.3]},
                "nodes":[
                    {">":"div", "margin":[3,3,3,3], "display":"inline-block",
                         "width":15, "height":15, "image":"Search.png", "color":"lightgreen"},
                    {">":"div","display":"inline", "text":"file:///src/SamplePages/test.json",
                    "font": {"color":"black", "size":15, "lineHeight":1.4, "family":"sans"} }
                    ]
                }
    ]
}



```

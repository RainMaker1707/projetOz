functor
import
    ProjectLib
    Browser
    OS
    System
    Application
define
    CWD = {Atom.toString {OS.getCWD}}#"/"
    Browse = proc {$ Buf} {Browser.browse Buf} end
    Print = proc{$ S} {System.print S} end
    Args = {Application.getArgs record('nogui'(single type:bool default:false optional:true)
									  'db'(single type:string default:CWD#"database/database.txt"))} 
in
    local ListOfCharacters TreeBuilder GameDriver NoGUI in
        fun {TreeBuilder L}
            /*
            TODO
            Return a tree built from a list of records
            */
            tree(q:'Porte-t-il des lunettes ?'  true: ['Harry Potter' 'Minerva McGonagall'] 
            false: tree(q:'Est-ce que c\'est une fille ?' true:['Hermione Granger'] false:['Ron Weasley']))
        end
        fun {GameDriver Tree}
            local Result in
                case Tree
                    of nil then Result = false
                    [] _|_ then 
                        {ProjectLib.found Tree Result}
                        if Result == false then {Print {ProjectLib.surrender}}
                        else {Print Result} end
                        unit % must return unit (project request)
                    [] tree(q:Q true:T false:F) then
                        if {ProjectLib.askQuestion Q} then {GameDriver T}
                        else {GameDriver F} end
                end
            end
        end
        ListOfCharacters = {ProjectLib.loadDatabase file Args.'db'}
        NoGUI = Args.'nogui'
        {ProjectLib.play opts(characters:ListOfCharacters driver:GameDriver 
                            noGUI:NoGUI builder:TreeBuilder)}
        {Application.exit 0}
    end
end

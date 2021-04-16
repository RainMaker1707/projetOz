functor
import
    ProjectLib
    Browser
    OS
    Application
    PrintL
    TreeBuilderFun
define
    CWD = {Atom.toString {OS.getCWD}}#"/"
    PrintList = proc{$ L} {PrintL.printer L} end
    Browse = proc {$ Buf} {Browser.browse Buf} end
    TreeBuilder = fun{$ L} {TreeBuilderFun.treeBuilderF L} end
    Args = {Application.getArgs record('nogui'(single type:bool default:false optional:true)
									  'db'(single type:string default:CWD#"database/database.txt")
                                      'ans'(single type:string default:CWD#"database/test_answer.txt")
                                      )} 
in
    local 
        GameDriver  
        Options 
    in
        fun {GameDriver Tree}
            local SearchNode Inner TreeSave in
                fun {SearchNode Tree Current}
                    case Tree
                        of leaf(_|_) then false
                        [] question(1:Q true:T false:F) then
                            if Current == T orelse Current == F then Tree
                            else 
                                local X in
                                    X = {SearchNode T Current}
                                    case X
                                        of question(1:_ true:_ false:_) then X
                                        else {SearchNode F Current}
                                    end
                                end
                            end 
                    end
                end
                fun {Inner Tree}
                    local Result in
                        case Tree
                            of nil then {ProjectLib.surrender}
                            [] leaf(_|_) then 
                                {ProjectLib.found Tree.1 Result}
                                if Result == false then {ProjectLib.surrender}
                                else 
                                    case Result
                                        of _|_ then {PrintList Result} 
                                        else {PrintList Result|nil}
                                    end
                                end 
                                unit % must return unit (project request)
                            [] question(1:Q true:T false:F) then
                                local Ans = {ProjectLib.askQuestion Q} in
                                    if Ans == true then {Inner T}
                                    elseif Ans == false then {Inner F} 
                                    % here TODO gestion of unknow answer
                                    elseif Ans == oops then 
                                        if TreeSave == Tree then {Inner Tree}
                                        else {Inner {SearchNode TreeSave Tree}}
                                        end
                                    end
                                end
                        end
                    end
                end
                TreeSave = Tree
                {Inner Tree}
            end
        end

        Options = opts( %allowUnknown:true
                        oopsButton:true
                        characters:{ProjectLib.loadDatabase file Args.'db'}
                        driver:GameDriver 
                        noGUI:Args.'nogui'
                        builder:TreeBuilder
                        autoPlay:{ProjectLib.loadCharacter file Args.'ans'}
                    )
        {ProjectLib.play Options}
        {Application.exit 0}
    end
end

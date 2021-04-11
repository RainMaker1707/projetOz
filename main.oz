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
									  'db'(single type:string default:CWD#"database/databaseTest.txt"))} 
in
    local ListOfCharacters TreeBuilder GameDriver NoGUI Options in
        fun {TreeBuilder L}
            /*
            Return a tree built from a list of records
            */
            local Counter QList Delta Keys Builder Spliter in
                fun {Counter L Q Acc}
                    /*
                    Count the difference between True (+) and false (-) answer
                    to a question Q in the list of characters L
                    return Acc with contains abs(n*True - m*false)
                    */
                    case L
                        of nil then % return abs(Acc)
                            if Acc >= 0 then Acc 
                            else Acc * ~1
                            end
                        [] H|T then
                            if H.Q == true then {Counter T Q Acc+1}
                            elseif H.Q == false then {Counter T Q Acc-1}
                            else {Counter T Q Acc}
                            end
                    end
                end
                fun {QList L Q}
                    /*
                    Take a list of characters and return a list of Question delta true false
                    */
                    case Q
                        of nil then nil
                        [] H|T then 
                            if H == 1 then {QList L T}
                            else {Counter L H 0}|{QList L T}
                            end
                    end
                end
                fun {Spliter L Q LTrue LFalse}
                    /*
                    Split the list L about question Q answer true or false
                    if the answer of question Q is unknow then character is append in both lists
                    */
                    case L
                        of nil then r(trueList:LTrue falseList:LFalse)
                        [] H|T then
                            try
                                if H.Q == true then {Spliter T Q H|LTrue LFalse}
                                else {Spliter T Q LTrue H|LFalse}
                                end
                            catch _ then
                                {Spliter T Q H|LTrue H|LFalse} % gestion of incertitude on db
                            end
                    end
                end
                fun {Builder L K D}
                    local SearchMin KeyAtIndex RemoveAtIndex CharList Index Q S T F in
                        fun {SearchMin L Min MinIndex CurrentIndex}
                            /*
                            L: list of int (here delta of true false answer)
                            Min delta: minimum value, setup to -1 to run because delta is absolute values
                            MinIndex: index of the minimum registred in Min
                            CurrentIndex: index of the current element tested 
                            */
                            case L
                                of nil then MinIndex
                                [] H|T then
                                    if Min == ~1 then {SearchMin T H CurrentIndex CurrentIndex+1}
                                    elseif H < Min then {SearchMin T H CurrentIndex CurrentIndex+1}
                                    else {SearchMin T Min MinIndex CurrentIndex+1}
                                    end
                                end
                        end
                        fun {KeyAtIndex K I}
                            /*
                            K: keys list provided by Arity function
                            I: int index of the key to return
                            return the question at index I
                            */
                            case K
                                of H|T then
                                    if I == 0 then H
                                    else {KeyAtIndex T I-1}
                                    end
                            end
                        end
                        fun {RemoveAtIndex L I Flag}
                            /*
                            revome item in list at index I+1 if flag or I else
                            */
                            case L
                                of nil then nil
                                [] H|T then 
                                    if Flag then
                                        if I == 0 then T
                                        else H|{RemoveAtIndex T I-1 Flag}
                                        end
                                    else
                                        if I == 1 then T
                                        else H|{RemoveAtIndex T I-1 Flag}
                                        end
                                    end
                            end
                        end
                        fun {CharList L}
                            /*
                            return the list of the characters name 
                            in the record liste passed as argument
                            */
                            case L
                                of nil then nil
                                [] H|T then H.1|{CharList T}
                            end
                        end
                        % main code of  tree builder
                        case D
                            of nil then {CharList L}
                            [] _|_ then
                                Index = {SearchMin D ~1 0 1}
                                Q = {KeyAtIndex K Index}
                                S = {Spliter L Q nil nil}
                                if S.trueList == nil orelse S.falseList == nil then
                                    % remove useless question
                                    {Builder L {RemoveAtIndex K Index true} {RemoveAtIndex D Index false}}
                                else
                                    T = {Builder S.trueList {RemoveAtIndex K Index true} {RemoveAtIndex D Index false}}
                                    F = {Builder S.falseList {RemoveAtIndex K Index true} {RemoveAtIndex D Index false}}
                                    tree(q:Q true:T false:F)
                                end
                        end
                    end
                end
                % TODO for extension differents number of question:
                % replace {Arity L.1} by the {Arity (max arity L.x)}
                Keys = {Arity L.1} % return list of record L.1 keys without the key 1 from t(1:<char name> ...)
                Delta = {QList L Keys} % return the delta true-false in absolute value for each question in Keys
                {Builder L Keys Delta}
            end
        end
        fun {GameDriver Tree}
            local Result in
                case Tree
                    of nil then {ProjectLib.surrender}
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
        Options = opts(characters:ListOfCharacters 
                              driver:GameDriver 
                              noGUI:NoGUI 
                              builder:TreeBuilder
                              autoPlay:{ProjectLib.loadCharacter file CWD#"database/test_answers.txt"}
                            )
        {ProjectLib.play Options}
        {Application.exit 0}
    end
end

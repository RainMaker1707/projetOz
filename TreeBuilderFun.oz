functor
import
    Browser
export
    TreeBuilderF
define
    Browse = proc {$ B} {Browser.browse B} end
    fun {TreeBuilderF L}
        /*
        Return a tree built from a list of records
        */
        local 
            QList 
            Builder 
            Delta 
            Keys
            MaximumArity 
        in
            fun {QList L Q}
                /*
                Take a list of characters and return a list of Question delta true false
                */
                local Counter in
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
                                try
                                    if H.Q == true then {Counter T Q Acc+1}
                                    else {Counter T Q Acc-1}
                                    end
                                catch _ then 
                                    {Counter T Q Acc}
                                end
                        end
                    end
                    case Q
                        of nil then nil
                        [] H|T then 
                            if H == 1 then {QList L T}
                            else {Counter L H 0}|{QList L T}
                            end
                    end
                end
            end
            fun {Builder L K D}
                local 
                    SearchMin 
                    KeyAtIndex 
                    RemoveAtIndex 
                    Spliter 
                    CharList
                in
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
                    fun {RemoveAtIndex L I}
                        /*
                        revome item in list at index I+1 if flag or I else
                        */
                        case L
                            of nil then nil
                            [] H|T then 
                                if I == 0 then T
                                else H|{RemoveAtIndex T I-1}
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
                            local Index Q S in
                                Index = {SearchMin D ~1 0 1}
                                Q = {KeyAtIndex K Index}
                                S = {Spliter L Q nil nil}
                                if (S.trueList == nil orelse S.falseList == nil) orelse (S.trueList == S.falseList) then
                                    % remove useless question
                                    local Ky in
                                        Ky = {RemoveAtIndex K Index}
                                        {Builder L Ky {QList L Ky}}
                                    end
                                else
                                    local Ky T F in
                                        Ky = {RemoveAtIndex K Index}
                                        T = {Builder S.trueList Ky {QList S.trueList Ky}}
                                        F = {Builder S.falseList Ky {QList S.falseList Ky}}
                                        tree(q:Q true:T false:F)
                                    end
                                end
                            end
                    end
                end
            end
            
            fun {MaximumArity L Max ArityMax}
                /*
                Function which search the maximum arity then 
                return the longuest length list of keys in record list
                */
                local Length in
                    fun {Length L Acc}
                        case L
                            of nil then Acc
                            [] _|T then {Length T Acc+1}
                        end
                    end
                    case L
                        of nil then ArityMax
                        [] H|T then 
                            if Max < {Length {Arity H} 0} then {MaximumArity T {Length {Arity H} 0} {Arity H}}
                            else {MaximumArity T Max ArityMax} end
                    end
                end
            end
            
            Keys = {MaximumArity L 0 zero()} % return list of record keys
            Delta = {QList L Keys} % return the delta true-false in absolute value for each question in Keys
            %{Browse {Builder L Keys Delta}} % uncomment to browse the tree 
            {Builder L Keys Delta}
        end
    end
end
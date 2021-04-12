functor
import
    Open
export 
    Printer
define
    OF = {New Open.file init(name:stdout flags:[write create truncate text])}
    proc {Printer L}
        case L
        of H|nil then
            {OF write(vs:H#"\n")}
        []H|T then
            {OF write(vs:H#",")}
            {Printer T}
        end
    end
end
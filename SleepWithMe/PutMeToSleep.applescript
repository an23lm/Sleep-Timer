script PutMeToSleep
    property parent: class "NSObject"
    on sush()
        do shell script "pmset sleepnow"
    end sush
end script

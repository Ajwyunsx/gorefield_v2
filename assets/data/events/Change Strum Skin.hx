var preloadedFrames:Map<String, Dynamic> = [];
var preloadedNames:Map<String, Dynamic> = [];
var daPixelZoom = 6;
var isActuallyPixel = false;
function create()
    for (event in PlayState.SONG.events) {
        var skin = event.params[0] == "gorefield" ? "default" : event.params[0];
        var isPixel = event.params[1];
        if (event.name == "Change Strum Skin" && !preloadedFrames.exists(skin)){
            if(isPixel){
                preloadedFrames.set(skin, Paths.image("game/pixel/" + skin + "/Notes"));
            }
            else{
                preloadedFrames.set(skin, Paths.getFrames("game/notes/" + skin));
            }
            preloadedNames.set(skin,skin);
        }
    }

var strumAnimPrefix = ["left", "down", "up", "right"];
function onEvent(eventEvent)
    if (eventEvent.event.name == "Change Strum Skin") {
        var skin:String = eventEvent.event.params[0] == "gorefield" ? "default" : eventEvent.event.params[0];
        var isPixel:Bool = isActuallyPixel = eventEvent.event.params[1];
        for (strumLine in strumLines)
            for (i => strum in strumLine.members) {
                var oldAnimName:String = strum.animation.name;
                var oldAnimFrame:Int = strum.animation?.curAnim?.curFrame;
                if (oldAnimFrame == null) oldAnimFrame = 0;

                strum.frames = isPixel ? null : preloadedFrames[skin];
                strum.animation.destroyAnimations();

                if(isPixel){
                    strum.loadGraphic(preloadedFrames[skin], true, 17, 17);
                    strum.animation.add("static", [strum.ID]);
                    strum.animation.add("pressed", [4 + strum.ID, 8 + strum.ID], 12, false);
                    strum.animation.add("confirm", [12 + strum.ID, 16 + strum.ID], 24, false);
                    strum.antialiasing = false;
                }
                else{
                    strum.animation.addByPrefix('static', 'arrow' + strumAnimPrefix[i % strumAnimPrefix.length].toUpperCase());
                    strum.animation.addByPrefix('pressed', strumAnimPrefix[i % strumAnimPrefix.length] + ' press', 24, false);
                    strum.animation.addByPrefix('confirm', strumAnimPrefix[i % strumAnimPrefix.length] + ' confirm', 24, false);
                    strum.antialiasing = true;
                }

                strum.scale.set(isPixel ? daPixelZoom : 0.7,isPixel ? daPixelZoom : 0.7);
                strum.updateHitbox();

                strum.playAnim(oldAnimName, true);
                strum.animation?.curAnim?.curFrame = oldAnimFrame;
            }
    }
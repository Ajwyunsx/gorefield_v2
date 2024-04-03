package lime.utils;

import haxe.PosInfos;
import haxe.Exception;
import funkin.backend.system.Logs as FunkinLogs;
#if js
import flixel.FlxG;
#elseif sys
import sys.io.File;
import sys.FileSystem;
#end
	
using StringTools;


#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Log
{
	public static var level:LogLevel;

	public static function debug(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.DEBUG)
		{
			#if js
			untyped __js__("console").debug("[" + info.className + "] " + message);
			#else
			println("[" + info.className + "] " + Std.string(message));
			#end

		}
	}

	public static function error(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.ERROR)
		{
			var message = '[${info.className}] $message';

			#if sys
			try
			{
				if (!FileSystem.exists('crash'))
					FileSystem.createDirectory('crash');
				
				File.saveContent('crash/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', message);
			} catch (e:Exception)
				FunkinLogs.trace('Couldn\'t save error message. (${e.message})', WARNING, YELLOW);
			#end

			#if (mobile || windows)
			lime.app.Application.current.window.alert(message, "Error!");
			#else
			FunkinLogs.trace(message, ERROR, RED);
			#end

			#if js
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			
			js.Browser.window.location.reload(true);
			#else
			lime.system.System.exit(1);
			#end
		}
	}

	public static function info(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.INFO)
			FunkinLogs.trace('[${info.className}] $message', INFO, RED);
	}

	public static inline function print(message:Dynamic):Void
	{
		#if sys
		Sys.print(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped __js__("console").log(message);
		#else
		trace(message);
		#end
	}

	public static inline function println(message:Dynamic):Void
	{
		#if sys
		Sys.println(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped __js__("console").log(message);
		#else
		trace(Std.string(message));
		#end
	}

	public static function verbose(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.VERBOSE)
			FunkinLogs.trace('[${info.className}] $message', VERBOSE);
	}

	public static function warn(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.WARN)
		{
			FunkinLogs.trace('[${info.className}] $message', WARNING, YELLOW);
		}
	}

	private static function __init__():Void
	{
		#if no_traces
		level = NONE;
		#elseif verbose
		level = VERBOSE;
		#else
		#if sys
		var args = Sys.args();
		if (args.indexOf("-v") > -1 || args.indexOf("-verbose") > -1)
		{
			level = VERBOSE;
		}
		else
		#end
		{
			#if debug
			level = DEBUG;
			#else
			level = INFO;
			#end
		}
		#end

		#if js
		if (untyped __js__("typeof console") == "undefined")
		{
			untyped __js__("console = {}");
		}
		if (untyped __js__("console").log == null)
		{
			untyped __js__("console").log = function() {};
		}
		#end
	}
}

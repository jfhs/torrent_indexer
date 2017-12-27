import std.stdio;
import std.net.curl;
import std.conv;
import std.regex;
import std.algorithm;
import std.range.primitives : empty;

enum Language {
	RU,
	EN,
}

enum VideoSize {
	vs720p,	
	vs1080p,
}

enum VideoCodec {
	H256,
	MP4,
}

enum ContainerType {
	AVI,
	MKV,
	MP4,
}

enum AudioCodec {
	DEFAULT,
}

struct TorrentInfo {
	string title;
	int tid;
	int fid;
	Language[] audioLanguages;
	Language[] subtitleLanguages;
	VideoSize videoSize;
	VideoCodec videoCodec;
	ContainerType container;
	Language[AudioCodec[]] audioCodecs;
	string imdbURL;
	string kpURL;
}

string getPage(int page, int fid) {
	return to!string(get(text("https://rutracker.org/forum/viewforum.php?f=", fid, "&start=", page * 50)));
}

string getTopic(int tid) {
	return to!string(get(text("https://rutracker.org/forum/viewtopic.php?t=", tid)));
}

static auto topicTitleRe = ctRegex!(`<a id="topic-title"[^>]+?>(.+?)</a>`);
static auto linksRe = ctRegex!(`<a href="(.+?)" class="postLink"`);

string[] getLinks(string str) {
	string[] result = [];
	foreach(m; matchAll(str, linksRe)) {
		result ~= m[1];
	}
	return result;
}

bool isImdbURL(string url) {
	return url.startsWith("http://www.imdb.com/");
}

bool isKpURL(string url) {
	return url.startsWith("https://www.kinopoisk.ru/");
}

T getOrDefault(T)(T[] a, T def = null) {
	return a.empty ? def : a[0];
}

TorrentInfo parseTopic(int tid, string data) {
	TorrentInfo result;
	auto titleM = matchFirst(data, topicTitleRe);
	if (titleM) {
		result.title = titleM[1];
	}
	auto links = getLinks(data);
	result.imdbURL = getOrDefault(links.find!isImdbURL());
	result.kpURL = getOrDefault(links.find!isKpURL());
	return result;
}

void main() {
	int tid = 5499060;
	auto result = parseTopic(tid, getTopic(tid));
	writeln(result.title);
	writeln(result.imdbURL);
	writeln(result.kpURL);
}

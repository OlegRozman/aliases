#!/bin/sh

#    FFMPEG

ff_cp() { ffmpeg -ss $1 -to $2 -i $3 -c copy $4; }
    # начало фрагмента, конец, исходный файл, выходной файл
    # ff_cp 00:02:30 00:13:58 12.mp4 out.mp4
    # ff_cp 10 50 12.mp4 out.mp4 - c 10 по 50 секунду
	
# конверт для телека h265 - h264, in и out расширение mp4
ff_tv() { ffmpeg -i $1 -c:v libx264 -c:a copy $2; }
	
# компрессия
ff_css_va() { ffmpeg -i $1 -c:v libx265 -c:a aac $2; }
ff_css_v() { ffmpeg -i $1 -c:v libx265 -c:a copy $2; }

# crop
# ffmpeg -i in.mp4 -filter:v "crop=500:720:500:0" out.mp4
# ширина:высота:координаты верхнего левого угла
# если координаты не указывать, то обрезка центрируется


#    YT-DLP

# By default yt-dlp tries to download the best available quality
# Каталог сохранения указан в конфиге
# Ссылки подставляемые вместо параметра могут содержать символы которые нужно экранировать поэтому ссылки нужно ставить в кавычки, однако параметр кавычить бесполезно, так как он проверяется интерпретатором до подстановки

# плейлисты
alias yplck='yt-dlp --cookies yck -S "res:720" -o "/mnt/data/tmp/yt-dlp/WatchLater/%(playlist_index)s - %(title)s" $1'
alias ypl4='yt-dlp -S "res:480" -o "/mnt/data/tmp/yt-dlp/pl/%(playlist_index)s - %(title)s" $(wl-paste)'
alias ypl7='yt-dlp -S "res:720" -o "/mnt/data/tmp/yt-dlp/pl/%(playlist_index)s - %(title)s" $(wl-paste)' 
alias ypl10='yt-dlp -S "res:1080" -o "/mnt/data/tmp/yt-dlp/pl/%(playlist_index)s - %(title)s" $(wl-paste)' 
    # скачивание плейлиста с автонумерацией согласно плейлисту, с ведущими нулями; 
	  # лучшее доступное видео с самым большим разрешением, но не лучше 720p
    # параметр -o перебивает параметр в конфиге, поэтому нужно указать путь
    # yck - cookie-файл для скачивания плейлиста "См позже"

alias y7='yt-dlp -S "res:720" $(wl-paste) ; nice nautilus /mnt/data/tmp/yt-dlp/'

y7f() { link=$(wl-paste);
	name="$(yt-dlp --print filename $link)";
	echo $name;
	yt-dlp -S "res:720" $link;
	mv "$name" "$(echo "$name" | sed 's/[:："？＂?.№ —,;!&]/_/g' | sed 's/__/_/g' | sed 's/_webm/.webm/')";
	nice nautilus /mnt/data/tmp/yt-dlp/; }
y4f() { link=$(wl-paste);
	name="$(yt-dlp --print filename $link)";
	echo $name;
	yt-dlp -S "res:480" $link;
	mv "$name" "$(echo "$name" | sed 's/[:："？＂?.№ —,;!&]/_/g' | sed 's/__/_/g' | sed 's/_webm/.webm/')";
	nice nautilus /mnt/data/tmp/yt-dlp/; }

alias y4='yt-dlp -S "res:480" $(wl-paste) ; nice nautilus /mnt/data/tmp/yt-dlp/'
alias y10='yt-dlp -S "res:1080" $(wl-paste) ; nice nautilus /mnt/data/tmp/yt-dlp/'
alias y7p='yt-dlp -S "res:720" $1'
alias ydlp='~/.scripts/ydlp.sh'

alias ybt='yt-dlp $(wl-paste)' 
alias yl='yt-dlp -F $(wl-paste)' # список форматов
alias yf='yt-dlp $(wl-paste) -f $1' # качать формат на выбор ($1 - номер формата)
alias ya='yt-dlp -x'
alias ymp3='yt-dlp -x --audio-format mp3'

#!/bin/sh


# ........................  IMAGEMAGIC  ........................

pngtojpg () { for file in *.png; do magick "$file" "${file/.png/.jpg}"; done }

alias picresizeone='magick $1 -scale $2% -quality 80 $3'
# исходный файл; проценты масштабирования; выходной файл

# переменные ..._value принимают значения позиционных параметров $1 и $2, 
# имеющих значения по-умолчанию : 100 и 80
picresize() { 
	      mkdir resize
	      scale_value=${1:-100}
	      quality_value=${2:-80}
	      for i in *.* 
	          do magick "$i" -scale $scale_value% -quality $quality_value ./resize/"$i"
	      done 
	      echo $scale_value
	      echo $quality_value 
     	    }

alias picrotate='mogrify -rotate $1 *.*'

picrotatef() { mkdir rotate;
	      for i in *.*
                  do convert "$i" -rotate $1 ./rotate/"$i"
	      done }



# ...........................  PDF  .............................


alias pdftojpg='pdftocairo -jpeg $1'   # $1 - имя pdf файла


#........................... Lumix ..............................
# для фото и видео с камеры Lumix: дату в имя плюс конвертация видео
lumix() {
	mkdir ./tmp ./tmp/1
	for file in *.MTS
		do file_rn=$(date -d @$(stat -c %Y $file) '+%Y-%m-%d_%H-%M-%S').mts
		cp "$file" ./tmp/1/$file_rn
		ff_css_v ./tmp/1/$file_rn ./tmp/"${file_rn/.mts/.mp4}"
	done

	for file in *.JPG
		do file_rn=$(date -d @$(stat -c %Y $file) '+%Y-%m-%d_%H-%M-%S').jpg
		cp "$file" ./tmp/$file_rn
	done
}


# ..........................  FFMPEG  ...........................

ff_i() { for file in *; do
		# Проверяем, существует ли файл
		if [[ -f "$file" ]]; then
			echo "Файл: $file"
			ffprobe -i "$file" 2>&1 | grep "Video:"
			echo "---------------------------------"
		fi
	done
}


ff_cp() { ffmpeg -ss $1 -to $2 -i $3 -c copy $4; }
    # начало фрагмента, конец, исходный файл, выходной файл
    # ff_cp 00:02:30 00:13:58 12.mp4 out.mp4
    # ff_cp 10 50 12.mp4 out.mp4 - c 10 по 50 секунду
	
# конверт для телека h265 - h264, in и out расширение mp4
ff_tv() { if [ ! -d "conv" ]; then mkdir conv; fi; ffmpeg -i $1 -c:v libx264 -c:a copy ./conv/"$1"; }
	
# компрессия
ff_css_va() { if [ ! -d "conv" ]; then mkdir conv; fi; ffmpeg -i $1 -c:v libx265 -preset slow -crf 23 -c:a aac ./conv/"$1"; }
ff_css_v() { if [ ! -d "conv" ]; then mkdir conv; fi; ffmpeg -i $1 -c:v libx265 -preset slow -crf 23 -c:a copy ./conv/"$1"; }

ff_css_720() { if [ ! -d "conv" ]; then mkdir conv; fi; ffmpeg -i $1 -vf scale=-2:720 -c:v libx265 -preset slow -crf 23 -c:a copy ./conv/"$1"; }
ff_css_480() { if [ ! -d "conv" ]; then mkdir conv; fi; ffmpeg -i $1 -vf scale=-2:480 -c:v libx265 -preset slow -crf 23 -c:a copy ./conv/"$1"; }

ff_css_v_all() { 
    mkdir conv
    for file in ./*.mp4
    do ffmpeg -i "$file" -c:v libx265 -preset slow -crf 23 -c:a copy ./conv/"$file"
    done }

ff_css_720_all() { 
    mkdir conv
    for file in ./*.mp4
    do ffmpeg -i "$file" -vf scale=-2:720 -c:v libx265 -preset slow -crf 23 -c:a copy ./conv/"$file"
    done }

ff_css_480_all() { 
    mkdir conv
    for file in ./*.mp4;
    do ffmpeg -i "$file" -vf scale=-2:480 -c:v libx265 -preset slow -crf 23 -c:a copy ./conv/"$file"
    done }


# аудио - извлечение
# определение кодека, чтобы установить нужное **расширение** имени файла.
# ffmpeg -i video.mp4
# $1 - input_video.mp4 
ff_audio() { ffmpeg -i $1 -vn -acodec copy ./conv/"$file"; }

# crop
# ffmpeg -i in.mp4 -filter:v "crop=500:720:500:0" out.mp4
# ширина:высота:координаты верхнего левого угла
# если координаты не указывать, то обрезка центрируется



# ............................  YT-DLP ............................

# запуск nautilus не использовать, команда открывает каталог в запущенном экземпляре и путает открытые вкладки

# By default yt-dlp tries to download the best available quality
# Каталог сохранения указан в конфиге
# Ссылки подставляемые вместо параметра могут содержать символы которые нужно экранировать поэтому ссылки нужно ставить в кавычки, однако параметр кавычить бесполезно, так как он проверяется интерпретатором до подстановки

# -P, --paths [TYPES:]PATH   The paths where the files should be downloaded.
# путь сохранения в конфиг файле имеет приоритет, необходимо закомментировать строку
# если не указывать путь сохранение, то по-умолчанию в корень домашнего каталога
yt_dlp_outdir=/mnt/data/y-dk/tmp/video

proxy='socks5://127.0.0.1:2080'

# плейлисты
alias yplck='yt-dlp --cookies yck -S "res:720" -o "$yt_dlp_outdir/WatchLater/%(playlist_index)s - %(title)s" --proxy $proxy $1'
alias ypl4='yt-dlp -S "res:480" -o "$yt_dlp_outdir/pl/%(playlist_index)s - %(title)s" --proxy $proxy $(wl-paste)'
alias ypl7='yt-dlp -S "res:720" -o "$yt_dlp_outdir/pl/%(playlist_index)s - %(title)s" --proxy $proxy $(wl-paste)' 
alias ypl10='yt-dlp -S "res:1080" -o "$yt_dlp_outdir/pl/%(playlist_index)s - %(title)s" --proxy $proxy $(wl-paste)' 
    # скачивание плейлиста с автонумерацией согласно плейлисту, с ведущими нулями; 
	  # лучшее доступное видео с самым большим разрешением, но не лучше 720p
    # параметр -o перебивает параметр в конфиге, поэтому нужно указать путь
    # yck - cookie-файл для скачивания плейлиста "См позже"



y10f() { link=$(wl-paste);
	title="$(yt-dlp --print title --proxy $proxy $link)";
	filename="$(yt-dlp --print filename --proxy $proxy $link)";
	ext="$(yt-dlp --print ext --proxy $proxy $link)";
	echo "\n\n$title\n\n$filename\n\n$ext\n\n";
	new_title=$(echo "$title" | sed 's/[^а-яА-Яa-zA-Z0-9]/_/g' | sed 's/__/_/g' | sed 's/_$//g');
	yt-dlp -S "res:1080" --proxy $proxy $link && mv "$filename" ~/download/"$new_title.$ext" 
}


y7f() { link=$(wl-paste);
	title="$(yt-dlp --print title --proxy $proxy $link)";
	filename="$(yt-dlp --print filename --proxy $proxy $link)";
	ext="$(yt-dlp --print ext --proxy $proxy $link)";
	echo "\n\n$title\n\n$filename\n\n$ext\n\n";
	new_title=$(echo "$title" | sed 's/[^а-яА-Яa-zA-Z0-9]/_/g' | sed 's/__/_/g' | sed 's/_$//g');
	yt-dlp -S "res:720" --proxy $proxy $link && mv "$filename" ~/download/"$new_title.$ext" 
}

y7f_nopx() { link=$(wl-paste);
	title="$(yt-dlp --print title $link)";
	filename="$(yt-dlp --print filename $link)";
	ext="$(yt-dlp --print ext $link)";
	echo "\n\n$title\n\n$filename\n\n$ext\n\n";
	new_title=$(echo "$title" | sed 's/[^а-яА-Яa-zA-Z0-9]/_/g' | sed 's/__/_/g' | sed 's/_$//g');
	yt-dlp -S "res:720" $link && mv "$filename" ~/download/"$new_title.$ext" 
}

y4f() { link=$(wl-paste);
	title="$(yt-dlp --print title --proxy $proxy $link)";
	filename="$(yt-dlp --print filename --proxy $proxy $link)";
	ext="$(yt-dlp --print ext --proxy $proxy $link)";
	echo "\n\n$title\n\n$filename\n\n$ext\n\n";
	new_title=$(echo "$title" | sed 's/[^а-яА-Яa-zA-Z0-9]/_/g' | sed 's/__/_/g' | sed 's/_$//g');
	yt-dlp -S "res:480" --proxy $proxy $link && mv "$filename" ~/download/"$new_title.$ext" 
}


alias yl='yt-dlp -F --proxy $proxy $(wl-paste)' # список форматов

# когда нужно скачать не в каталог, указанный в конфиге (он на yk)
alias y7download='yt-dlp -S "res:720" -o "~/download/%(title)s" --proxy $proxy $(wl-paste)'

# когда нет нужного единого формата видео+аудио
# yf 136+140  или:
# yt-dlp -f 137+140 -o "~/download/%(title)s" $(wl-paste) 
alias yf='yt-dlp --proxy $proxy $(wl-paste) -f $1' # качать формат на выбор ($1 - номер формата)

alias y7='yt-dlp -S "res:720" --proxy $proxy $(wl-paste)'
alias y4='yt-dlp -S "res:480" --proxy $proxy $(wl-paste)'
alias y10='yt-dlp -S "res:1080" --proxy $proxy $(wl-paste)'
alias y7p='yt-dlp -S "res:720" --proxy $proxy $1'
alias ydlp='~/.scripts/ydlp.sh'

alias ybt='yt-dlp --proxy $proxy $(wl-paste)' 
alias yaudio='yt-dlp -x --proxy $proxy $(wl-paste)' # качает лучшее качество
alias ymp3='yt-dlp -x --audio-format mp3 --proxy $proxy $(wl-paste)'



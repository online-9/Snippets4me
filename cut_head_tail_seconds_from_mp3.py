import argparse
import os
from pydub import AudioSegment


def cut_file(song, start_to_miliseconds, end_to_miliseconds):
    song = AudioSegment.from_mp3(song)
    if args.start:
        start_to_miliseconds = args.start * 1000
        song = song[start_to_miliseconds:]
    if args.end:
        end_to_miliseconds = args.end * 1000
        song = song[:-end_to_miliseconds]
    return song


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Remove head and/or tail from mp3")
    parser.add_argument("input", help="from /path/to/file or /path/to/dir")
    parser.add_argument("-o","--output", help="to /path/to/file or /path/to/dir")
    parser.add_argument("-s", "--start", help="cut {-s} seconds from the beginning of the audio file", type=int)
    parser.add_argument("-e", "--end", help="cut {-e} seconds from the end of the audio file", type=int)
    args = parser.parse_args()

    if os.path.isdir(args.input):
        for n in os.listdir(args.input):
            if os.path.isdir(n):
                pass
            else:
                try:
                    cut_file(n, args.start, args.end).export(n[:-4]+"_CHANGED.mp3", format="mp3")
                except:
                    pass
    else:
        if not args.output:
            cut_file(args.input, args.start, args.end).export(args.input[:-4] + "_CHANGED.mp3", format="mp3")
        else:
            cut_file(args.input,args.start, args.end).export(args.output, format="mp3")







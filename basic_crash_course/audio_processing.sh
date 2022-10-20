"""
file 'file1.mp3'
file 'file2.mp3'
file 'file3.mp3'
"""
 
 # Bash script to ffmpeg command to join mp3s
 ffmpeg -f concat -safe 0 -i files.txt -c copy output.mp3
  

# Convert mp3 to mp4
ffmpeg -i input.mp3 -loop 1 -i pic.jpg -shortest -c:a copy -c:v mjpeg output.mp4

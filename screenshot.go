package main

import (
	"bytes"
	"crypto/sha1"
	"flag"
	"fmt"
	"image/png"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"time"

	"github.com/kolesa-team/go-webp/encoder"
	"github.com/kolesa-team/go-webp/webp"
	"github.com/sqweek/dialog"
	"github.com/thiagokokada/hyprland-go"
)

const (
	screenshotsDir = "Pictures/Screenshots/"
	swappyTmpFile  = "/tmp/swappy.png"
	swappyTmpFile2 = "/tmp/swappy2.png"
	swappyWebpFile = "/tmp/swappy.webp"
)

var (
	title                string
	titleScreenshotsPath string

	c *hyprland.RequestClient
)

func fileEror(str, file string, err error) {
	if err != nil {
		log.Fatalf(str+" %s: %v", file, err)
	}
}

func copy(srcFile, dstFile string) {
	src, err := os.Open(srcFile)
	fileEror("Error opening", srcFile, err)
	defer src.Close()

	dst, err := os.Create(dstFile)
	fileEror("Error creating", dstFile, err)
	defer dst.Close()

	_, err = io.Copy(dst, src)
	if err != nil {
		log.Fatalf("Error copying %s to %s: %v", srcFile, dstFile, err)
	}
}

func main() {
	c = hyprland.MustClient()
	bactive := flag.Bool("a", false, "Screenshots the active window")
	bselect := flag.Bool("s", false, "Screenshots the area you select")
	bwindow := flag.Bool("w", false, "Screenshots the window you click")
	flag.Parse()

	homeDir, err := os.UserHomeDir()
	eror("Error getting user home directory", err)

	fullScreenshotsPath := filepath.Join(homeDir, screenshotsDir)
	if _, err := os.Stat(fullScreenshotsPath); os.IsNotExist(err) {
		err = os.MkdirAll(fullScreenshotsPath, 0755)
		eror("Error creating screenshots directory", err)
	}

	os.Remove(swappyTmpFile)
	os.Remove(swappyWebpFile)

	_, err = os.Create(swappyTmpFile)
	fileEror("Error creating", swappyTmpFile, err)

	copy(swappyTmpFile, swappyTmpFile2)

	grimCmd := exec.Command("grim", "-")
	if *bselect || *bwindow {
		samuraiCmd := exec.Command("samurai-select")
		if *bwindow {
			samuraiCmd = exec.Command("samurai-select", "-r", "hyprland")
		}
		samuraiOutput, err := samuraiCmd.Output()
		if err != nil {
			if exitError, ok := err.(*exec.ExitError); ok {
				if len(samuraiOutput) == 0 && len(exitError.Stderr) == 0 {
					log.Println("samurai-select cancelled or returned empty selection, exiting.")
					return
				}
				log.Fatalf("samurai-select exited with error: %v\nStderr: %s", exitError, exitError.Stderr)
			}
			log.Fatalf("Error running samurai-select: %v", err)
		}
		selection := string(bytes.TrimSpace(samuraiOutput))
		grimCmd = exec.Command("grim", "-g", selection, "-")
	} else if *bactive {
		activeWindow, err := c.ActiveWindow()
		if err != nil {
			fmt.Printf("Error getting hyprland active window: %v", err)
			return
		}
		start := strconv.Itoa(activeWindow.At[0]) + "," + strconv.Itoa(activeWindow.At[1])
		size := strconv.Itoa(activeWindow.Size[0]) + "x" + strconv.Itoa(activeWindow.Size[1])
		title = activeWindow.Title

		titleScreenshotsPath = filepath.Join(fullScreenshotsPath, "/"+title)
		if _, err := os.Stat(titleScreenshotsPath); os.IsNotExist(err) {
			err = os.MkdirAll(titleScreenshotsPath, 0755)
			eror("Error creating screenshots directory", err)
		}

		grimCmd = exec.Command("grim", "-g", start+" "+size, "-")
	}
	swappyCmd := exec.Command("swappy", "-f", "-")

	swappyCmd.Stdin, err = grimCmd.StdoutPipe()
	eror("Error creating grim stdout pipe", err)

	if err := grimCmd.Start(); err != nil {
		log.Fatalf("Error starting grim: %v", err)
	}

	if err := swappyCmd.Start(); err != nil {
		log.Fatalf("Error starting swappy: %v", err)
	}

	if err := grimCmd.Wait(); err != nil {
		log.Printf("grim exited with error: %v", err)
	}

	if err := swappyCmd.Wait(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			log.Fatalf("swappy exited with error: %v\nStderr: %s", exitError, exitError.Stderr)
		}
		log.Fatalf("Error running swappy: %v", err)
	}

	swappyPngContent, err := os.ReadFile(swappyTmpFile)
	fileEror("Error reading", swappyTmpFile, err)
	sha1SwappyPng := sha1.Sum(swappyPngContent)

	swappyPng2Content, err := os.ReadFile(swappyTmpFile2)
	fileEror("Error reading", swappyTmpFile2, err)
	sha1SwappyPng2 := sha1.Sum(swappyPng2Content)

	if !bytes.Equal(sha1SwappyPng[:], sha1SwappyPng2[:]) {
		tmpName := fmt.Sprintf("screenshot-%s", time.Now().Format("2006:01:02:15:04:05"))

		saveName := ""
		var err error
		if *bactive {
			saveName, err = dialog.File().Title("Save your file").Filter("Webp files", "webp").SetStartDir(titleScreenshotsPath).SetStartFile(tmpName + ".webp").Save()
		} else {
			saveName, err = dialog.File().Title("Save your file").Filter("Webp files", "webp").SetStartDir(fullScreenshotsPath).SetStartFile(tmpName + ".webp").Save()
		}
		if err != nil {
			if err == dialog.Cancelled {
				fmt.Println("Save dialog cancelled.")
			} else {
				fmt.Printf("Error: %v\n", err)
			}
			return
		}

		pngFile, err := os.Open(swappyTmpFile)
		if err != nil {
			log.Fatalf("Error opening %s for WebP conversion: %v", swappyTmpFile, err)
		}
		defer pngFile.Close()

		img, err := png.Decode(pngFile)
		fileEror("Error decoding PNG from", swappyTmpFile, err)

		webpFile, err := os.Create(swappyWebpFile)
		if err != nil {
			log.Fatalf("Error creating %s for WebP output: %v", swappyWebpFile, err)
		}
		defer webpFile.Close()

		options, err := encoder.NewLossyEncoderOptions(encoder.PresetDefault, 100)
		eror("Error creating webp encoder options: %v", err)

		err = webp.Encode(webpFile, img, options)
		fileEror("Error encoding WebP to", swappyWebpFile, err)

		copy(swappyWebpFile, saveName)
	} else {
		log.Println("Screenshot not modified by swappy, not saving.")
	}
}

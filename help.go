package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
)

func getHelp(scmd string) string {
	cmd := exec.Command(scmd, "--help")

	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	eror("failed to run --help for "+scmd+"\n"+stderr.String(), cmd.Run())

	return stdout.String()
}

func getManPage(scmd string) string {
	cmd := exec.Command("man", scmd)

	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	eror("failed to run man command for "+scmd+"\n"+stderr.String(), cmd.Run())

	return stdout.String()
}

func getTldr(scmd string) string {
	cmd := exec.Command("tldr", "-m", scmd)

	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	eror("failed to run tldr command for "+scmd+"\n"+stderr.String(), cmd.Run())

	return stdout.String()
}

func main() {
	if len(os.Args) > 1 {
		cmd := os.Args[1]
		prompt := "You are an ai and this is an automated request, i need you to describe the command " + cmd + " i want you to give useful examples, however, also try to be concise, so no extra fluff like explaining your thoughts\n\n"
		prompt += "here is the TLDR for " + cmd + "\n"
		prompt += "```" + getTldr(cmd) + "```\n\n"
		prompt += "here is the Man Page for " + cmd + "\n"
		prompt += "```" + getManPage(cmd) + "```\n\n"
		prompt += "here is the --help for " + cmd + "\n"
		prompt += "```" + getHelp(cmd) + "```\n\n"
		prompt += "here is all of the users additional context\n"
		prompt += "```"
		for i := 2; i < len(os.Args); i++ {
			prompt += os.Args[i]
		}
		prompt += "```"

		loadTokens()
		fmt.Println(GemRequest("models/gemini-2.5-flash-preview-04-17", prompt))
	} else {
		fmt.Println("This is the help command from the Amadeus Dotifles,\n
		you can run `help command` to get help for that command,\n
		you can do the same with man or tldr,
		you should also use jump for directory navigation")
	}
}

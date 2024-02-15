package main

import (
	"github.com/gin-gonic/gin"
	"strings"
	"strconv"
	"net/http"
	// "time"
	"os"
	"fmt"

	config "backend.alloy.phyce.dev/config"
)

func main() {
	config.ReadConfig()
	router := gin.Default()

	// API routes
	apiRoutes := router.Group("/api")
	{
		apiRoutes.GET("/example", func(context *gin.Context) {
			context.JSON(200, gin.H{"message": "Hello from API"})
		})
	}

	router.GET("/app.wasm", func(c *gin.Context) {
		filePath := "./public/app/app.wasm"
		fileInfo, err := os.Stat(filePath)
		if err != nil {
			// Handle file access errors
			c.Status(http.StatusInternalServerError)
			return
		}

		// Get Unix timestamp of the file's last modification
		fileLastModifiedUnix := fileInfo.ModTime().Unix()
		fmt.Println("fileLastModifiedUnix")
		fmt.Println(fileLastModifiedUnix)

		// Extract 'timestamp' query parameter and convert to Unix timestamp
		timestampStr := c.Query("timestamp")
		if timestampStr != "" {
			providedTimestamp, err := strconv.ParseInt(timestampStr, 10, 64)
			if err != nil {
				// Handle invalid timestamp format
				c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid timestamp format"})
				return
			}

			// If the provided timestamp exactly matches the file's last modified timestamp
			if providedTimestamp == fileLastModifiedUnix {
				// Return a specific JSON response indicating no update is needed
				c.JSON(http.StatusOK, gin.H{"last_updated": 0})
				return
			}
		}
		c.File(filePath)
	})

	// Static files/folders
	router.Static("/app", "./public/app/")
	router.Static("/img", "./public/img/")

	// Default/Fallback route
	router.NoRoute(func(c *gin.Context) {
		if strings.HasPrefix(c.Request.URL.Path, "/api/") {
			c.Next()
		} else {
			c.File("public/index.html")
		}
	})

	if config.Ssl.Enabled {
		router.RunTLS(":" + strconv.Itoa(config.HttpPort),
			config.Ssl.Certificate, 
			config.Ssl.PrivateKey,
		)
	} else {
		router.Run(":" + strconv.Itoa(config.HttpPort))
	}
}
package main

import (
	"log"
	"os"
	"todo-backend/database"
	"todo-backend/handlers"

	"github.com/gin-gonic/gin"
)

func main() {
	// Kết nối Database (đã có logic retry trong db.go của bạn)
	database.ConnectDB()

	router := gin.Default()
	router.SetTrustedProxies(nil)

	// Middleware CORS đơn giản để React gọi được API
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Định nghĩa các Routes
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Backend ToDo API is running!",
		})
	})
	router.GET("/tasks", handlers.GetTasks)
	router.POST("/tasks", handlers.CreateTask)
	router.PUT("/tasks/:id", handlers.UpdateTask)
	router.DELETE("/tasks/:id", handlers.DeleteTask)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Khởi chạy server trên cổng được cấu hình
	if err := router.Run(":" + port); err != nil {
		log.Fatal("LỖI: Không thể khởi chạy server:", err)
	}
}

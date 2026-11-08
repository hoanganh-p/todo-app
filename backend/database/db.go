package database

import (
	"fmt"
	"log"
	"os"
	"time"
	"todo-backend/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// Hàm retry kết nối DB
func connectWithRetry(dsn string) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	for i := 0; i < 10; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err == nil {
			sqlDB, err2 := db.DB()
			if err2 == nil {
				if err = sqlDB.Ping(); err == nil {
					log.Println("Kết nối Database thành công")
					return db, nil
				}
			} else {
				err = err2
			}
		}

		log.Printf("Chưa thể kết nối DB, retry %d/10...\n", i+1)
		time.Sleep(5 * time.Second)
	}

	return nil, err
}

// Hàm chính để connect DB
func ConnectDB() {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	db, err := connectWithRetry(dsn)
	if err != nil {
		log.Fatal("LỖI: Không thể kết nối Database:", err)
	}

	// Lấy sql.DB để config pool
	sqlDB, err := db.DB()
	if err != nil {
		log.Fatal("Lỗi khi lấy sql.DB:", err)
	}

	// Cấu hình connection pool (khuyến nghị)
	sqlDB.SetMaxOpenConns(10)
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetConnMaxLifetime(time.Hour)

	// Auto migrate có check lỗi
	if err := db.AutoMigrate(&models.Task{}, &models.User{}); err != nil {
		log.Fatal("Migration failed:", err)
	}

	DB = db
	log.Println("Database ready!")
}

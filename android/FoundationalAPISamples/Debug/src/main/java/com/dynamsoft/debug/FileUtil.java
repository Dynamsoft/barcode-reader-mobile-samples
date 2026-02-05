package com.dynamsoft.debug;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class FileUtil {

    private FileUtil() {
    }

    /**
     * Zips a folder.
     * @param srcFileString The path of the source folder.
     * @param zipFileString The path of the destination zip file.
     * @throws IOException if an I/O error has occurred.
     */
    public static void zipFolder(String srcFileString, String zipFileString) throws IOException {
        File srcFolder = new File(srcFileString);
        if (!srcFolder.exists()) {
            return;
        }

        try (FileOutputStream fileOutputStream = new FileOutputStream(new File(zipFileString));
             ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream)) {
            zipFile(srcFolder, "", zipOutputStream);
        }
    }

    /**
     * Private helper method to zip files.
     * Note: This method seems to be a duplicate of zipFolder and is not used by any other public method.
     * @param folderPath The path of the source folder.
     * @param zipFilePath The path of the destination zip file.
     * @throws IOException if an I/O error has occurred.
     */
    private static void zipFiles(String folderPath, String zipFilePath) throws IOException {
        File zipFile = new File(zipFilePath);
        try (FileOutputStream fileOutputStream = new FileOutputStream(zipFile);
             ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream)) {
            zipFile(new File(folderPath), "", zipOutputStream);
        }
    }

    /**
     * Recursively zips a file or directory.
     * @param file The file or directory to zip.
     * @param parentPath The parent path within the zip archive.
     * @param zipOutputStream The ZipOutputStream to write to.
     * @throws IOException if an I/O error has occurred.
     */
    private static void zipFile(File file, String parentPath, ZipOutputStream zipOutputStream) throws IOException {
        String filePath = parentPath + file.getName();
        if (file.isFile()) {
            try (FileInputStream fileInputStream = new FileInputStream(file)) {
                zipOutputStream.putNextEntry(new ZipEntry(filePath));
                byte[] buffer = new byte[1024];
                int len;
                while ((len = fileInputStream.read(buffer)) > 0) {
                    zipOutputStream.write(buffer, 0, len);
                }
                zipOutputStream.closeEntry();
            }
        } else { // It's a directory
            File[] fileList = file.listFiles();
            if (fileList == null || fileList.length == 0) {
                // Handle empty directory
                zipOutputStream.putNextEntry(new ZipEntry(filePath + "/"));
                zipOutputStream.closeEntry();
            } else {
                for (File childFile : fileList) {
                    zipFile(childFile, filePath + "/", zipOutputStream);
                }
            }
        }
    }

    /**
     * Deletes a directory and all its contents.
     * @param dir The directory to delete.
     */
    public static void deleteDirWithFiles(File dir) {
        if (dir != null && dir.exists() && dir.isDirectory()) {
            File[] files = dir.listFiles();
            if (files != null) {
                for (File file : files) {
                    if (file.isDirectory()) {
                        deleteDirWithFiles(file); // Recursively delete subdirectories
                    } else {
                        file.delete(); // Delete file
                    }
                }
            }
            dir.delete(); // Delete the now-empty directory
        }
    }
}

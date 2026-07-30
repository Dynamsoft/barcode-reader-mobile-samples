package com.dynamsoft.gridbarcodereading;

enum EnumGridStatus {
    GS_DECODED("Decoded"),
    GS_DEEP_DECODED("Deep Decoded"),
    GS_FAILED("Failed");

    private final String description;

    EnumGridStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

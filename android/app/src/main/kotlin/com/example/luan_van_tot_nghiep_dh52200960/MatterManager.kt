package com.example.luan_van_tot_nghiep_dh52200960

class MatterManager{
    private val useMockMatter  = true
    fun commissionDevice(setupCode: String): Map<String, Any> {
        return if (useMockMatter ){
            commissionDeviceMock(setupCode)
        } else {
            commissionDeviceReal(setupCode);
        }
    }

    fun toggleDevice(deviceId: String, targetState: Boolean): Boolean {
        return if (useMockMatter ){
            toggleDeviceMock(deviceId, targetState)
        } else {
            toggleDeviceReal(deviceId, targetState)
        }
    }

    private fun commissionDeviceMock(setupCode: String): Map<String, Any> {
        return mapOf(
            "id" to "matter_${System.currentTimeMillis()}",
            "name" to "Thiết bị Matter",
            "room" to "Phòng khách",
            "type" to "Light",
            "endpoint" to "1",
            "cluster" to "OnOff",
            "isOn" to false,
            "isConnected" to true,
            "setupCode" to setupCode,
        )
    }

    private fun toggleDeviceMock(deviceId: String, targetState: Boolean): Boolean {
        println("MatterManager MOCK: deviceId=$deviceId, targetState=$targetState")
        return true;
    }

    private fun commissionDeviceReal(setupCode: String): Map<String, Any> {
        // Sau này tích hợp Google Home Mobile SDK hoặc Matter Android SDK tại đây.
        throw NotImplementedError("Chưa tích hợp Matter SDK thật")
    }

    private fun toggleDeviceReal(deviceId: String, targetState: Boolean): Boolean {
        // Sau này gửi lệnh On/Off cluster đến thiết bị Matter thật tại đây.
        throw NotImplementedError("Chưa tích hợp điều khiển Matter thật")
    }
}
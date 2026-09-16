# UO.GetTradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

傳回交易對方角色的數值 serial。

## 完整語法

```text
UO.GetTradeOpponent(TradeNum:Any) -> Any
```

## 參數

- `TradeNum` — 目前視窗的整數編號：1..TradeCount()。零及負數無效。不是 serial。

## 傳回值

Integer：視窗 LocalSerial 中的對方角色 serial；視窗不存在時為 0。不是容器或 Boolean；用 <> 0 判斷。

## 行為

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade 從 1 編號；TradeContainer/TradeOpponent/TradeName 及所有 TradeCheck 形式從 0 索引。本客戶端保留這些慣例；不同引擎的外部手冊可能採用不同起點。
- 在遊戲執行緒讀取目前 World 中尚未關閉的視窗，排除已釋放視窗。讀取不送封包、不等待回覆。開啟、關閉或將視窗移到最前方可能改變 UI 順序；索引不是永久 ID。
- ConfirmTrade 及寫入自己的 TradeCheck 只在同意狀態改變時送封包。對方方塊由伺服器控制。CancelTrade 只送一次。1/TRUE 表示本機狀態或處理，不表示轉移完成。名稱與雙方勾選不能證明物品未變。

### 內部函式：從呼叫到結果

以下說明 C# 呼叫路徑，之後提供可執行的 Basic 範例。腳本不會重新實作網路協定。

#### 1. ExecuteStealthCompatibility

註冊依參數數量選擇形式，NumberConversions 轉換數字。兩參數 TradeCheck 驗證 1/2 側別後映射到 bridge 的 0/1。舊形式 serial 由 ToHex 格式化。

Integer：視窗 LocalSerial 中的對方角色 serial；視窗不存在時為 0。不是容器或 Boolean；用 <> 0 判斷。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponent

Invoke 將讀寫轉到遊戲執行緒並支援腳本取消；讀取指定 TradingGump 的 ID1/ID2、LocalSerial、OpponentName 或核取狀態。

傳回交易對方角色的數值 serial。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `GetTradeOpponent`.

#### 3. FindNumberedTrade

FindNumberedTrade 在減 1 前檢查 number>0；FindTrade 拒絕負索引，只列舉目前 World 尚未關閉的 TradingGump。

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade 從 1 編號；TradeContainer/TradeOpponent/TradeName 及所有 TradeCheck 形式從 0 索引。本客戶端保留這些慣例；不同引擎的外部手冊可能採用不同起點。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindNumberedTrade`.

輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色 serial，不是價格或內容驗證。


## 範例

### 直接讀取或操作

```vb
# 直接讀取或操作
#
# 傳回交易對方角色的數值 serial。
#
# Integer：視窗 LocalSerial 中的對方角色 serial；視窗不存在時為 0。不是容器或 Boolean；用 <> 0 判斷。

SUB Main()
    # 只呼叫一次，將結果保存在 value/result。0 是第一個索引，1 是第一個編號（請看語法）。HEX 顯示數值 serial；CStr 顯示數字或文字。

    VAR value = UO.GetTradeOpponent(1)
    UO.Print(HEX(value))
END SUB
```

**參數與執行說明:**

- 只呼叫一次，將結果保存在 value/result。0 是第一個索引，1 是第一個編號（請看語法）。HEX 顯示數值 serial；CStr 顯示數字或文字。

### 另一情境與參數

```vb
# 另一情境與參數
#
# 傳回交易對方角色的數值 serial。
#
# Integer：視窗 LocalSerial 中的對方角色 serial；視窗不存在時為 0。不是容器或 Boolean；用 <> 0 判斷。

SUB Main()
    # total 保存視窗數，index 是目前索引或編號。列舉不會同意交易。GetTradeContainer 範例讀取視窗 1 中自己的容器 (1) 與對方容器 (2)。

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponent(index)
        UO.Print(CStr(index) + ": " + HEX(value))
    NEXT
END SUB
```

**參數與執行說明:**

- total 保存視窗數，index 是目前索引或編號。列舉不會同意交易。GetTradeContainer 範例讀取視窗 1 中自己的容器 (1) 與對方容器 (2)。

### 完整可呼叫輔助函式

```vb
# 完整可呼叫輔助函式
#
# 傳回交易對方角色的數值 serial。
#
# Integer：視窗 LocalSerial 中的對方角色 serial；視窗不存在時為 0。不是容器或 Boolean；用 <> 0 判斷。

SUB Main()
    # 輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色
    # serial，不是價格或內容驗證。

    VAR value = ReadTradeValue(1)
    UO.Print(HEX(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 1 OR index >= total + 1 THEN
        RETURN 0
    END IF
    RETURN UO.GetTradeOpponent(index)
END FUNCTION
```

**參數與執行說明:**

- 輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色 serial，不是價格或內容驗證。

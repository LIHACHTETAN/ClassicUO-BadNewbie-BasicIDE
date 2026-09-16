# UO.ConfirmTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

在指定交易中設定自己的同意狀態。

## 完整語法

```text
UO.ConfirmTrade(TradeNum:Any) -> Any
```

## 參數

- `TradeNum` — 目前視窗的整數編號：1..TradeCount()。零及負數無效。不是 serial。

## 傳回值

Integer：視窗存在且自己的同意已設定或原本已設定時為 1 = TRUE；否則 0 = FALSE。不證明伺服器已完成交易。重複呼叫不會取消同意。

這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

## 行為

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade 從 1 編號；TradeContainer/TradeOpponent/TradeName 及所有 TradeCheck 形式從 0 索引。本客戶端保留這些慣例；不同引擎的外部手冊可能採用不同起點。
- 在遊戲執行緒讀取目前 World 中尚未關閉的視窗，排除已釋放視窗。讀取不送封包、不等待回覆。開啟、關閉或將視窗移到最前方可能改變 UI 順序；索引不是永久 ID。
- ConfirmTrade 及寫入自己的 TradeCheck 只在同意狀態改變時送封包。對方方塊由伺服器控制。CancelTrade 只送一次。1/TRUE 表示本機狀態或處理，不表示轉移完成。名稱與雙方勾選不能證明物品未變。

### 內部函式：從呼叫到結果

以下說明 C# 呼叫路徑，之後提供可執行的 Basic 範例。腳本不會重新實作網路協定。

#### 1. ExecuteStealthCompatibility

註冊依參數數量選擇形式，NumberConversions 轉換數字。兩參數 TradeCheck 驗證 1/2 側別後映射到 bridge 的 0/1。舊形式 serial 由 ToHex 格式化。

Integer：視窗存在且自己的同意已設定或原本已設定時為 1 = TRUE；否則 0 = FALSE。不證明伺服器已完成交易。重複呼叫不會取消同意。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. ConfirmTrade

Invoke 將讀寫轉到遊戲執行緒並支援腳本取消；讀取指定 TradingGump 的 ID1/ID2、LocalSerial、OpponentName 或核取狀態。

在指定交易中設定自己的同意狀態。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `ConfirmTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade 在減 1 前檢查 number>0；FindTrade 拒絕負索引，只列舉目前 World 尚未關閉的 TradingGump。

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade 從 1 編號；TradeContainer/TradeOpponent/TradeName 及所有 TradeCheck 形式從 0 索引。本客戶端保留這些慣例；不同引擎的外部手冊可能採用不同起點。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindNumberedTrade`.

#### 4. AcceptTrade

自己的方塊改變時，GameActions.AcceptTrade 以代碼 2、ID1 及狀態呼叫 Send_TradeResponse。讀取及設定相同值不送封包。

Integer：視窗存在且自己的同意已設定或原本已設定時為 1 = TRUE；否則 0 = FALSE。不證明伺服器已完成交易。重複呼叫不會取消同意。

專案原始碼: `src/ClassicUO.Client/Game/GameActions.cs`; 函式 `AcceptTrade`.

輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色 serial，不是價格或內容驗證。


## 範例

### 直接讀取或操作

```vb
# 直接讀取或操作
#
# 在指定交易中設定自己的同意狀態。
#
# Integer：視窗存在且自己的同意已設定或原本已設定時為 1 = TRUE；否則 0 = FALSE。不證明伺服器已完成交易。重複呼叫不會取消同意。
#
# 這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result
# = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE
# 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

SUB Main()
    # 只呼叫一次，將結果保存在 value/result。0 是第一個索引，1 是第一個編號（請看語法）。HEX 顯示數值 serial；CStr 顯示數字或文字。

    VAR result = UO.ConfirmTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**參數與執行說明:**

- 只呼叫一次，將結果保存在 value/result。0 是第一個索引，1 是第一個編號（請看語法）。HEX 顯示數值 serial；CStr 顯示數字或文字。

### 另一情境與參數

```vb
# 另一情境與參數
#
# 在指定交易中設定自己的同意狀態。
#
# Integer：視窗存在且自己的同意已設定或原本已設定時為 1 = TRUE；否則 0 = FALSE。不證明伺服器已完成交易。重複呼叫不會取消同意。
#
# 這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result
# = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE
# 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

SUB Main()
    # ConfirmTrade 及寫入自己的 TradeCheck 只在同意狀態改變時送封包。對方方塊由伺服器控制。CancelTrade 只送一次。1/TRUE
    # 表示本機狀態或處理，不表示轉移完成。名稱與雙方勾選不能證明物品未變。

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.ConfirmTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**參數與執行說明:**

- ConfirmTrade 及寫入自己的 TradeCheck 只在同意狀態改變時送封包。對方方塊由伺服器控制。CancelTrade 只送一次。1/TRUE 表示本機狀態或處理，不表示轉移完成。名稱與雙方勾選不能證明物品未變。

### 完整可呼叫輔助函式

```vb
# 完整可呼叫輔助函式
#
# 在指定交易中設定自己的同意狀態。
#
# Integer：視窗存在且自己的同意已設定或原本已設定時為 1 = TRUE；否則 0 = FALSE。不證明伺服器已完成交易。重複呼叫不會取消同意。
#
# 這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result
# = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE
# 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

SUB Main()
    # 輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色
    # serial，不是價格或內容驗證。

    VAR expectedPartner = UO.GetTradeOpponent(1)
    VAR result = ApplyToPartner(1, expectedPartner)
    UO.Print(CStr(result))
END SUB

FUNCTION ApplyToPartner(tradeNumber, expectedPartner)
    IF expectedPartner = 0 THEN
        RETURN FALSE
    END IF
    IF UO.GetTradeOpponent(tradeNumber) <> expectedPartner THEN
        RETURN FALSE
    END IF
    RETURN UO.ConfirmTrade(tradeNumber)
END FUNCTION
```

**參數與執行說明:**

- 輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色 serial，不是價格或內容驗證。

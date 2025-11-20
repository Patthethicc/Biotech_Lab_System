package com.biotech.lis.Entity;

import java.util.List;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class InventoryPayload {
    private Inventory inventory;
    private List<ItemLoc> locations;
}


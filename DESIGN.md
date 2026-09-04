# Foundation Design

## Core loop

1. **Buy** inventory from distributors, collections, and opportunistic offers.
2. **Stock** limited storage and display space, choosing which products deserve visibility.
3. **Sell** to customers whose budgets, interests, and patience respond to price and availability.
4. **Pay bills** such as rent, payroll, and replenishment before cash runs out.
5. **Upgrade** fixtures, capacity, reputation, and staff to unlock better opportunities.

## Decision pressure

- Cash tied up in inventory cannot cover rent or sudden opportunities.
- High margins protect each sale but reduce volume and customer trust.
- Hype can create upside, while reprints and fading demand can strand expensive stock.
- Shelf and storage limits make assortment a strategic choice rather than an unlimited list.

## Engineering direction

Economy, inventory, customers, time, and shop capacity remain separate domains. Commands go to the owning service; cross-domain outcomes are broadcast as signals. Content definitions stay data-driven. Early vertical slices should prove one decision at a time before adding a broad simulation.

The next slice should connect a single purchasable product to receiving stock, assigning a shelf price, matching one customer desire, completing a ledger-backed sale, and advancing to a rent-bearing day.

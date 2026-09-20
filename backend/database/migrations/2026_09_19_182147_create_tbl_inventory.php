```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_inventory', function (Blueprint $table) {
            $table->bigIncrements('v_inventoryId');

            $table->unsignedBigInteger('v_productId')
                ->nullable();

            $table->unsignedBigInteger('v_materialId')
                ->nullable();

            $table->decimal('v_quantityOnHand', 14, 2)
                ->default(0.00);

            $table->decimal('v_quantityReserved', 14, 2)
                ->default(0.00);

            // Generated column
            // PostgreSQL requires quoted mixed-case column names.
            $table->decimal('v_quantityAvailable', 14, 2)
                ->storedAs('"v_quantityOnHand" - "v_quantityReserved"');

            $table->decimal('v_reorderLevel', 14, 2)
                ->nullable();

            $table->string('v_storageLocation', 150)
                ->nullable();

            $table->dateTime('v_lastStockUpdate')
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            // Product relationship
            $table->foreign(
                'v_productId',
                'fk_inventory_product'
            )
                ->references('v_productId')
                ->on('tbl_product')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            // Material relationship
            $table->foreign(
                'v_materialId',
                'fk_inventory_material'
            )
                ->references('v_materialId')
                ->on('tbl_material')
                ->onUpdate('cascade')
                ->onDelete('restrict');
        });

        // PostgreSQL check constraint must be added
        // AFTER the table has been created.
        DB::statement(
            'ALTER TABLE "tbl_inventory"
             ADD CONSTRAINT "chk_inventory_item"
             CHECK (
                 ("v_productId" IS NOT NULL AND "v_materialId" IS NULL)
                 OR
                 ("v_productId" IS NULL AND "v_materialId" IS NOT NULL)
             )'
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_inventory');
    }
};

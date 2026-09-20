```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_quotationItem', function (Blueprint $table) {
            $table->bigIncrements('v_quotationItemId');

            $table->unsignedBigInteger('v_quotationId');

            $table->string('v_itemType', 50)
                ->nullable();

            $table->unsignedBigInteger('v_productId')
                ->nullable();

            $table->unsignedBigInteger('v_materialId')
                ->nullable();

            $table->unsignedBigInteger('v_serviceId')
                ->nullable();

            $table->string('v_itemDescription', 255);

            $table->decimal('v_quantity', 14, 2)
                ->default(1.00);

            $table->string('v_unitOfMeasure', 50)
                ->nullable();

            $table->decimal('v_unitPrice', 14, 2)
                ->default(0.00);

            // Generated column
            // PostgreSQL requires quoted mixed-case column names.
            $table->decimal('v_lineAmount', 14, 2)
                ->storedAs('"v_quantity" * "v_unitPrice"');

            $table->text('v_notes')
                ->nullable();

            // Quotation relationship
            $table->foreign(
                'v_quotationId',
                'fk_quotationItem_quotation'
            )
                ->references('v_quotationId')
                ->on('tbl_quotation')
                ->onUpdate('cascade')
                ->onDelete('cascade');

            // Product relationship
            $table->foreign(
                'v_productId',
                'fk_quotationItem_product'
            )
                ->references('v_productId')
                ->on('tbl_product')
                ->onUpdate('cascade')
                ->onDelete('set null');

            // Material relationship
            $table->foreign(
                'v_materialId',
                'fk_quotationItem_material'
            )
                ->references('v_materialId')
                ->on('tbl_material')
                ->onUpdate('cascade')
                ->onDelete('set null');

            // Service relationship
            $table->foreign(
                'v_serviceId',
                'fk_quotationItem_service'
            )
                ->references('v_serviceId')
                ->on('tbl_service')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_quotationItem');
    }
};

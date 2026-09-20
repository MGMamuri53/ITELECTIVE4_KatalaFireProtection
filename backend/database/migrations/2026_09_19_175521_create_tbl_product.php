<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_product', function (Blueprint $table) {
            $table->bigIncrements('v_productId');

            $table->string('v_productCode', 60)->nullable()->unique();
            $table->string('v_productName', 150);
            $table->string('v_productCategory', 100)->nullable();
            $table->string('v_brand', 100)->nullable();
            $table->string('v_model', 100)->nullable();

            $table->text('v_productDescription')->nullable();

            $table->string('v_unitOfMeasure', 50)->nullable();

            $table->decimal('v_currentPrice', 14, 2)->nullable();
            $table->decimal('v_costPrice', 14, 2)->nullable();

            $table->string('v_supplierReference', 150)->nullable();
            $table->string('v_warrantyPeriod', 100)->nullable();

            $table->boolean('v_isActive')->default(true);

            $table->dateTime('v_createdAt')->useCurrent();
            $table->dateTime('v_updatedAt')->useCurrent();

            $table->index(
                'v_productName',
                'idx_product_productName'
            );

            $table->index(
                'v_productCategory',
                'idx_product_productCategory'
            );
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_product');
    }
};
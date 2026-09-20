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
        Schema::create('tbl_productPriceHistory', function (Blueprint $table) {
            $table->bigIncrements('v_productPriceHistoryId');

            $table->unsignedBigInteger('v_productId');

            $table->decimal('v_oldPrice', 14, 2)->nullable();
            $table->decimal('v_newPrice', 14, 2);

            $table->dateTime('v_effectiveDate')->useCurrent();

            $table->string('v_changeReason', 255)->nullable();

            $table->unsignedBigInteger('v_changedByUserId')->nullable();

            $table->dateTime('v_createdAt')->useCurrent();

            $table->foreign(
                'v_productId',
                'fk_productPriceHistory_product'
            )
                ->references('v_productId')
                ->on('tbl_product')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_changedByUserId',
                'fk_productPriceHistory_user'
            )
                ->references('v_userId')
                ->on('tbl_user')
                ->onUpdate('cascade')
                ->onDelete('set null');
                    });
                }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_productPriceHistory');
    }
};